import 'dart:io';

import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as img;
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class MlDetectionDataSource {
  Future<void> initialize();
  Future<DetectionResult> detectCatInPhoto(String photoPath);
  Future<List<DetectionResult>> detectCatsInBatch(List<String> photoPaths);
  void dispose();
}

class MlDetectionDataSourceImpl implements MlDetectionDataSource {
  static const String _modelAssetPath = 'assets/ml/cat_detection_model.tflite';
  static const int _inputSize = 224;
  static const double _confidenceThreshold = 0.7;

  Interpreter? _interpreter;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing ML cat detection model...');

      // Load the TensorFlow Lite model
      _interpreter = await Interpreter.fromAsset(_modelAssetPath);

      // Warm up the model with a dummy input
      await _warmUpModel();

      _isInitialized = true;
      AppLogger.info('ML cat detection model initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ML model', e, stackTrace);

      // Fallback to simple heuristic detection if ML model fails
      AppLogger.warning('Falling back to heuristic cat detection');
      _isInitialized = true; // Continue without ML model
    }
  }

  @override
  Future<DetectionResult> detectCatInPhoto(String photoPath) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (!_isInitialized) {
        await initialize();
      }

      // If interpreter is available, use ML detection
      if (_interpreter != null) {
        return await _mlDetection(photoPath, stopwatch);
      } else {
        // Fallback to heuristic detection
        return await _heuristicDetection(photoPath, stopwatch);
      }
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.error('Error in cat detection for $photoPath', e, stackTrace);

      // Return fallback detection
      return DetectionResult(
        hasCat: false,
        confidence: 0.0,
        boundingBoxes: const [],
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  @override
  Future<List<DetectionResult>> detectCatsInBatch(
    List<String> photoPaths,
  ) async {
    AppLogger.info(
      'Processing batch of ${photoPaths.length} photos for cat detection',
    );

    final List<DetectionResult> results = [];

    // Process in smaller chunks to manage memory
    const int chunkSize = 10;
    for (int i = 0; i < photoPaths.length; i += chunkSize) {
      final end = (i + chunkSize > photoPaths.length)
          ? photoPaths.length
          : i + chunkSize;
      final chunk = photoPaths.sublist(i, end);

      for (final photoPath in chunk) {
        final result = await detectCatInPhoto(photoPath);
        results.add(result);

        // Small delay to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 50));
      }

      AppLogger.debug(
        'Processed chunk ${(i ~/ chunkSize) + 1}/${(photoPaths.length / chunkSize).ceil()}',
      );
    }

    final catCount = results.where((r) => r.hasCat).length;
    AppLogger.info(
      'Batch processing complete: $catCount cats found in ${photoPaths.length} photos',
    );

    return results;
  }

  Future<DetectionResult> _mlDetection(
    String photoPath,
    Stopwatch stopwatch,
  ) async {
    // Load and preprocess image
    final File imageFile = File(photoPath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Could not decode image: $photoPath');
    }

    // Preprocess image for model
    final input = _preprocessImage(image);

    // Prepare output tensor [batch_size, num_classes]
    final output = List.filled(1 * 2, 0.0).reshape([1, 2]);

    // Run inference
    _interpreter!.run(input, output);

    stopwatch.stop();

    // Process results
    final catProbability = output[0][1]; // Index 1 for "cat" class
    final hasCat = catProbability >= _confidenceThreshold;

    AppLogger.debug(
      'ML detection for $photoPath: '
      'cat=${hasCat ? 'YES' : 'NO'}, '
      'confidence=${(catProbability * 100).toStringAsFixed(1)}%, '
      'time=${stopwatch.elapsedMilliseconds}ms',
    );

    return DetectionResult(
      hasCat: hasCat,
      confidence: catProbability,
      boundingBoxes: hasCat
          ? [
              BoundingBox(
                x: 0.1,
                y: 0.1,
                width: 0.8,
                height: 0.8,
                label: 'cat',
                labelConfidence: catProbability,
              ),
            ]
          : [],
      processingTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<DetectionResult> _heuristicDetection(
    String photoPath,
    Stopwatch stopwatch,
  ) async {
    AppLogger.debug('Using heuristic detection for $photoPath');

    // Simple heuristic based on filename and basic image analysis
    final fileName = photoPath.toLowerCase();
    final File imageFile = File(photoPath);

    // Check filename for cat-related keywords
    final catKeywords = ['cat', 'kitty', 'kitten', 'feline', 'meow'];
    final hasKeyword = catKeywords.any((keyword) => fileName.contains(keyword));

    // Basic image analysis (simplified)
    double confidence = 0.0;
    bool hasCat = false;

    if (hasKeyword) {
      confidence = 0.8;
      hasCat = true;
    } else {
      // Additional heuristic: analyze image metadata or simple pixel analysis
      confidence = await _analyzeImageContent(imageFile);
      hasCat = confidence >= _confidenceThreshold;
    }

    stopwatch.stop();

    AppLogger.debug(
      'Heuristic detection for $photoPath: '
      'cat=${hasCat ? 'YES' : 'NO'}, '
      'confidence=${(confidence * 100).toStringAsFixed(1)}%, '
      'time=${stopwatch.elapsedMilliseconds}ms',
    );

    return DetectionResult(
      hasCat: hasCat,
      confidence: confidence,
      boundingBoxes: hasCat
          ? [
              BoundingBox(
                x: 0.15,
                y: 0.15,
                width: 0.7,
                height: 0.7,
                label: 'cat (heuristic)',
                labelConfidence: confidence,
              ),
            ]
          : [],
      processingTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<double> _analyzeImageContent(File imageFile) async {
    try {
      // Basic image content analysis
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) return 0.0;

      // Simple heuristics based on image characteristics
      double confidence = 0.0;

      // Check image aspect ratio (cats often in landscape orientation)
      final aspectRatio = image.width / image.height;
      if (aspectRatio > 0.7 && aspectRatio < 1.5) {
        confidence += 0.2;
      }

      // Check image size (larger images more likely to contain subjects)
      if (image.width > 400 && image.height > 400) {
        confidence += 0.1;
      }

      // Color analysis for fur-like patterns (simplified)
      final avgColors = _analyzeAverageColors(image);
      if (_hasFurLikeColors(avgColors)) {
        confidence += 0.3;
      }

      // Random factor to simulate ML uncertainty
      confidence += (DateTime.now().millisecond % 20) / 100;

      return confidence.clamp(0.0, 1.0);
    } catch (e) {
      AppLogger.warning('Error in image content analysis: $e');
      return 0.0;
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image to model input size
    final img.Image resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Create input tensor [batch, height, width, channels]
    final input = List.generate(
      1, // batch size
      (b) => List.generate(
        _inputSize, // height
        (h) => List.generate(
          _inputSize, // width
          (w) => List.filled(3, 0.0), // RGB channels
        ),
      ),
    );

    // Fill tensor with normalized pixel values
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // Normalize to [-1, 1] range (common for MobileNet models)
        input[0][y][x][0] = (r / 127.5) - 1.0;
        input[0][y][x][1] = (g / 127.5) - 1.0;
        input[0][y][x][2] = (b / 127.5) - 1.0;
      }
    }

    return input;
  }

  Future<void> _warmUpModel() async {
    if (_interpreter == null) return;

    try {
      AppLogger.info('Warming up ML model...');

      // Create dummy input
      final dummyInput = List.generate(
        1,
        (b) => List.generate(
          _inputSize,
          (h) => List.generate(_inputSize, (w) => List.filled(3, 0.0)),
        ),
      );

      final output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      // Run dummy inference
      _interpreter!.run(dummyInput, output);

      AppLogger.info('Model warm-up complete');
    } catch (e) {
      AppLogger.warning('Model warm-up failed: $e');
    }
  }

  List<int> _analyzeAverageColors(img.Image image) {
    // Sample a few pixels to get average colors
    int totalR = 0, totalG = 0, totalB = 0;
    int sampleCount = 0;

    for (int y = 0; y < image.height; y += 20) {
      for (int x = 0; x < image.width; x += 20) {
        final pixel = image.getPixel(x, y);
        totalR += img.getRed(pixel);
        totalG += img.getGreen(pixel);
        totalB += img.getBlue(pixel);
        sampleCount++;
      }
    }

    if (sampleCount == 0) return [128, 128, 128];

    return [
      totalR ~/ sampleCount,
      totalG ~/ sampleCount,
      totalB ~/ sampleCount,
    ];
  }

  bool _hasFurLikeColors(List<int> avgColors) {
    final r = avgColors[0];
    final g = avgColors[1];
    final b = avgColors[2];

    // Common cat fur color ranges (simplified)
    final furColors = [
      [90, 60, 40], // Brown/tabby
      [200, 200, 200], // Gray
      [245, 245, 245], // White
      [50, 40, 35], // Dark/black
      [180, 130, 70], // Orange/ginger
    ];

    for (final furColor in furColors) {
      final distance =
          ((r - furColor[0]).abs() +
              (g - furColor[1]).abs() +
              (b - furColor[2]).abs()) /
          3;

      if (distance < 50) {
        // Threshold for color similarity
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    AppLogger.info('Disposing ML detection data source');
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
