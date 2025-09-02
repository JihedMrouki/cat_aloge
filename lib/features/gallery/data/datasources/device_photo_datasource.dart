import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as img;
import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:image/image.dart';
import 'package:image/image.dart' as img show decodeImage;
import 'package:photo_manager/photo_manager.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class DevicePhotoDataSource {
  Future<List<CatPhoto>> getDeviceCatPhotos();
  Future<List<AssetEntity>> getAllDevicePhotos();
  Future<DetectionResult> detectCatInPhoto(String photoPath);
  Future<void> refreshPhotos();
}

class DevicePhotoDataSourceImpl implements DevicePhotoDataSource {
  static const String _modelPath = 'assets/ml/cat_detection_model.tflite';
  static const int _inputSize = 224;
  static const double _confidenceThreshold = 0.7;

  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  final List<CatPhoto> _cachedCatPhotos = [];

  @override
  Future<List<CatPhoto>> getDeviceCatPhotos() async {
    try {
      AppLogger.info('Starting device cat photos scan...');

      // Return cached results if available
      if (_cachedCatPhotos.isNotEmpty) {
        AppLogger.info(
          'Returning ${_cachedCatPhotos.length} cached cat photos',
        );
        return _cachedCatPhotos;
      }

      // Get all photos from device
      final allPhotos = await getAllDevicePhotos();
      AppLogger.info('Found ${allPhotos.length} total photos on device');

      // Process photos in background isolate for better performance
      final catPhotos = await _processCatDetectionInBackground(allPhotos);

      _cachedCatPhotos.clear();
      _cachedCatPhotos.addAll(catPhotos);

      AppLogger.info('Successfully detected ${catPhotos.length} cat photos');
      return catPhotos;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting device cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<AssetEntity>> getAllDevicePhotos() async {
    try {
      // Request permissions
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        throw Exception('Photo permission denied');
      }

      // Get all photo albums
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        AppLogger.warning('No photo albums found');
        return [];
      }

      // Get photos from "All" album (first album contains all photos)
      final AssetPathEntity allPhotos = albums.first;
      final List<AssetEntity> photos = await allPhotos.getAssetListRange(
        start: 0,
        end: await allPhotos.assetCountAsync,
      );

      AppLogger.info('Retrieved ${photos.length} photos from device');
      return photos;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting device photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DetectionResult> detectCatInPhoto(String photoPath) async {
    try {
      await _ensureModelLoaded();

      // Load and preprocess image
      final File imageFile = File(photoPath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        return DetectionResult(
          hasCat: false,
          confidence: 0.0,
          boundingBoxes: [],
          processingTimeMs: 0,
        );
      }

      final stopwatch = Stopwatch()..start();

      // Resize and normalize image
      final img.Image resized = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );
      final input = _imageToInputTensor(resized);

      // Run inference
      final output = List.filled(
        1 * 2,
        0.0,
      ).reshape([1, 2]); // [batch, classes] - cat/no-cat
      _interpreter!.run(input, output);

      stopwatch.stop();

      // Process results
      final catProbability = output[0][1]; // Index 1 is "cat" class
      final hasCat = catProbability >= _confidenceThreshold;

      AppLogger.info(
        'Cat detection: ${hasCat ? 'CAT FOUND' : 'no cat'} '
        '(confidence: ${(catProbability * 100).toStringAsFixed(1)}%, '
        'time: ${stopwatch.elapsedMilliseconds}ms)',
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
                ), // Simplified bounding box
              ]
            : [],
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error detecting cat in photo: $photoPath',
        e,
        stackTrace,
      );
      return DetectionResult(
        hasCat: false,
        confidence: 0.0,
        boundingBoxes: [],
        processingTimeMs: 0,
      );
    }
  }

  @override
  Future<void> refreshPhotos() async {
    AppLogger.info('Refreshing device photos...');
    _cachedCatPhotos.clear();
    await getDeviceCatPhotos();
  }

  // Private helper methods

  Future<void> _ensureModelLoaded() async {
    if (_isModelLoaded && _interpreter != null) return;

    try {
      AppLogger.info('Loading TensorFlow Lite model...');
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isModelLoaded = true;
      AppLogger.info('TensorFlow Lite model loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load ML model', e, stackTrace);
      rethrow;
    }
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    final input = List.generate(
      1,
      (i) => List.generate(
        _inputSize,
        (j) => List.generate(_inputSize, (k) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // Normalize to [-1, 1] range
        input[0][y][x][0] = (r / 127.5) - 1.0;
        input[0][y][x][1] = (g / 127.5) - 1.0;
        input[0][y][x][2] = (b / 127.5) - 1.0;
      }
    }

    return input;
  }

  Future<List<CatPhoto>> _processCatDetectionInBackground(
    List<AssetEntity> photos,
  ) async {
    // Process in batches to avoid memory issues
    const int batchSize = 50;
    final List<CatPhoto> catPhotos = [];

    AppLogger.info(
      'Processing ${photos.length} photos in batches of $batchSize',
    );

    for (int i = 0; i < photos.length; i += batchSize) {
      final int end = (i + batchSize > photos.length)
          ? photos.length
          : i + batchSize;
      final batch = photos.sublist(i, end);

      AppLogger.info(
        'Processing batch ${(i ~/ batchSize) + 1}/${(photos.length / batchSize).ceil()}',
      );

      final batchResults = await _processBatch(batch);
      catPhotos.addAll(batchResults);

      // Small delay to prevent overwhelming the system
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return catPhotos;
  }

  Future<List<CatPhoto>> _processBatch(List<AssetEntity> batch) async {
    final List<CatPhoto> catPhotos = [];

    for (final AssetEntity asset in batch) {
      try {
        // Get file path
        final File? file = await asset.file;
        if (file == null) continue;

        // Detect cat in photo
        final DetectionResult detection = await detectCatInPhoto(file.path);

        if (detection.hasCat) {
          final catPhoto = CatPhoto(
            id: asset.id,
            path: file.path,
            fileName: asset.title ?? 'Unknown',
            dateAdded: asset.createDateTime,
            sizeBytes: await asset.size,
            width: asset.width,
            height: asset.height,
            detectionResult: detection,
          );

          catPhotos.add(catPhoto);
          AppLogger.debug(
            'Found cat in: ${asset.title} (confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%)',
          );
        }
      } catch (e) {
        AppLogger.warning('Error processing photo ${asset.title}: $e');
        continue;
      }
    }

    return catPhotos;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _cachedCatPhotos.clear();
    AppLogger.info('Device photo data source disposed');
  }
}

// Background isolate for heavy processing (future enhancement)
class _PhotoProcessingIsolate {
  static Future<List<String>> processPhotosInIsolate(
    List<String> photoPaths,
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);

    final SendPort sendPort = await receivePort.first;
    final ReceivePort responsePort = ReceivePort();

    sendPort.send([photoPaths, responsePort.sendPort]);
    final List<String> catPhotoPaths = await responsePort.first;

    return catPhotoPaths;
  }

  static void _isolateEntryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (final message in receivePort) {
      final List<String> photoPaths = message[0];
      final SendPort responsePort = message[1];

      // Process photos here (simplified for example)
      final List<String> catPhotos = photoPaths
          .where(
            (path) =>
                path.toLowerCase().contains('cat') ||
                path.toLowerCase().contains('kitty'),
          )
          .toList();

      responsePort.send(catPhotos);
      break;
    }
  }
}
