import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/detection_result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';

abstract class MlDetectionDataSource {
  Future<DetectionResult> detectCats(String imagePath);
  Future<void> loadModel();
  void dispose();
}

class MlDetectionDataSourceImpl implements MlDetectionDataSource {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  @override
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        AppConstants.catDetectionModelPath,
      );
      _isModelLoaded = true;
    } catch (e) {
      throw MLModelException('Failed to load ML model: $e');
    }
  }

  @override
  Future<DetectionResult> detectCats(String imagePath) async {
    if (!_isModelLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // Read and preprocess image
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw const MLModelException('Failed to decode image');
      }

      // Resize image to model input size (typically 224x224 for MobileNet)
      final img.Image resizedImage = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Convert to tensor format
      final input = _imageToByteListFloat32(resizedImage);

      // Run inference
      final output = <String, Object>{};
      _interpreter!.runForMultipleInputs([input], output.cast<int, Object>());

      // Parse results
      final detectionResults = _parseDetectionResults(output);

      return detectionResults;
    } catch (e) {
      throw MLModelException('Cat detection failed: $e');
    }
  }

  Float32List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(1 * 224 * 224 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        final pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) / 255.0);
        buffer[pixelIndex++] = (img.getGreen(pixel) / 255.0);
        buffer[pixelIndex++] = (img.getBlue(pixel) / 255.0);
      }
    }
    return convertedBytes;
  }

  DetectionResult _parseDetectionResults(Map<String, Object> output) {
    // This is a simplified example - actual implementation depends on your model output format
    final List<List<double>> detections = (output['detection_boxes'] as List)
        .cast<List<double>>();
    final List<double> scores = (output['detection_scores'] as List)
        .cast<double>();
    final List<double> classes = (output['detection_classes'] as List)
        .cast<double>();

    final List<BoundingBox> boundingBoxes = [];
    double maxConfidence = 0.0;
    bool hasCat = false;

    for (int i = 0; i < scores.length; i++) {
      final score = scores[i];
      final classId = classes[i];

      // Assuming class ID 17 is cat in COCO dataset
      if (classId == 17 && score > AppConstants.detectionThreshold) {
        hasCat = true;
        maxConfidence = score > maxConfidence ? score : maxConfidence;

        final detection = detections[i];
        boundingBoxes.add(
          BoundingBox(
            x: detection[1],
            y: detection[0],
            width: detection[3] - detection[1],
            height: detection[2] - detection[0],
            confidence: score,
          ),
        );
      }
    }

    return DetectionResult(
      hasCat: hasCat,
      confidence: maxConfidence,
      boundingBoxes: boundingBoxes,
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
  }
}

final mlDetectionDataSourceProvider = Provider<MlDetectionDataSource>((ref) {
  return MlDetectionDataSourceImpl();
});
