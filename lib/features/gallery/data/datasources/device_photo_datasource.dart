import 'dart:io';
import 'dart:typed_data';

import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class DevicePhotoDataSource {
  Future<List<CatPhoto>> getCatPhotos();
  Future<DetectionResult> detectCatInPhoto(String photoPath);
  Future<void> refreshPhotos();
  Future<void> clearCache();
  void dispose();
}

class DevicePhotoDataSourceImpl implements DevicePhotoDataSource {
  static const String _modelPath = 'assets/ml/cat_detection_model.tflite';
  static const int _inputSize = 224;
  static const double _confidenceThreshold = 0.7;

  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  final List<CatPhoto> _cachedCatPhotos = [];
  bool _isInitialized = false;

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    try {
      AppLogger.info('Getting cat photos from device...');

      if (!_isInitialized) {
        await _initialize();
      }

      // Return cached results if available
      if (_cachedCatPhotos.isNotEmpty) {
        AppLogger.info(
          'Returning ${_cachedCatPhotos.length} cached cat photos',
        );
        return List.from(_cachedCatPhotos);
      }

      // Scan device for cat photos
      return await _scanDeviceForCatPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DetectionResult> detectCatInPhoto(String photoPath) async {
    try {
      await _ensureModelLoaded();

      // Load and preprocess image
      final File imageFile = File(photoPath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: $photoPath');
      }

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

      // Use ML detection if model is loaded, otherwise fallback to heuristic
      DetectionResult result;
      if (_interpreter != null) {
        result = await _mlDetection(image, stopwatch);
      } else {
        result = await _heuristicDetection(photoPath, stopwatch);
      }

      AppLogger.debug(
        'Cat detection for $photoPath: ${result.hasCat ? 'CAT FOUND' : 'no cat'} '
        '(confidence: ${(result.confidence * 100).toStringAsFixed(1)}%, '
        'time: ${result.processingTimeMs}ms)',
      );

      return result;
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
    await getCatPhotos();
  }

  @override
  Future<void> clearCache() async {
    AppLogger.info('Clearing photo cache');
    _cachedCatPhotos.clear();
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _cachedCatPhotos.clear();
    _isInitialized = false;
    AppLogger.info('Device photo data source disposed');
  }

  // Private helper methods

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing device photo data source...');
      await _ensureModelLoaded();
      _isInitialized = true;
      AppLogger.info('Device photo data source initialized');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize device photo data source',
        e,
        stackTrace,
      );
      // Continue without ML model - will use heuristic detection
      _isInitialized = true;
    }
  }

  Future<void> _ensureModelLoaded() async {
    if (_isModelLoaded && _interpreter != null) return;

    try {
      AppLogger.info('Loading TensorFlow Lite model...');
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Warm up the model
      await _warmUpModel();

      _isModelLoaded = true;
      AppLogger.info('TensorFlow Lite model loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to load ML model, will use heuristic detection: $e',
      );
      _interpreter = null;
      _isModelLoaded = false;
    }
  }

  Future<List<CatPhoto>> _scanDeviceForCatPhotos() async {
    AppLogger.info('Starting device scan for cat photos...');

    // Request photo permission
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      throw Exception('Photo permission not granted');
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

    // Get photos from "All" album (contains all device photos)
    final AssetPathEntity allPhotos = albums.first;
    final int photoCount = await allPhotos.assetCountAsync;

    AppLogger.info('Found $photoCount total photos in device');

    // Process photos in batches to avoid memory issues
    const int batchSize = 50;
    final List<CatPhoto> allCatPhotos = [];

    for (int start = 0; start < photoCount; start += batchSize) {
      final int end = (start + batchSize > photoCount)
          ? photoCount
          : start + batchSize;

      AppLogger.info('Processing photos $start-$end of $photoCount');

      final List<AssetEntity> batch = await allPhotos.getAssetListRange(
        start: start,
        end: end,
      );

      final List<CatPhoto> batchCatPhotos = await _processBatch(batch);
      allCatPhotos.addAll(batchCatPhotos);

      AppLogger.debug('Batch complete: ${batchCatPhotos.length} cats found');

      // Small delay to prevent overwhelming the system
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Cache the results
    _cachedCatPhotos.clear();
    _cachedCatPhotos.addAll(allCatPhotos);

    AppLogger.info(
      'Device scan complete: ${allCatPhotos.length} cat photos found',
    );
    return List.from(allCatPhotos);
  }

  Future<List<CatPhoto>> _processBatch(List<AssetEntity> assets) async {
    final List<CatPhoto> catPhotos = [];

    for (final AssetEntity asset in assets) {
      try {
        // Get the actual file
        final File? file = await asset.file;
        if (file == null || !await file.exists()) {
          AppLogger.warning('Could not access file for asset: ${asset.id}');
          continue;
        }

        // Run cat detection
        final DetectionResult detection = await detectCatInPhoto(file.path);

        if (detection.hasCat) {
          final catPhoto = CatPhoto(
            id: asset.id,
            path: file.path,
            fileName:
                asset.title ?? 'IMG_${DateTime.now().millisecondsSinceEpoch}',
            dateAdded: asset.createDateTime,
            sizeBytes: asset.size,
            width: asset.width,
            height: asset.height,
            detectionResult: detection,
          );

          catPhotos.add(catPhoto);

          AppLogger.debug(
            'Cat detected in ${asset.title}: '
            '${(detection.confidence * 100).toStringAsFixed(1)}% confidence',
          );
        }
      } catch (e) {
        AppLogger.warning('Error processing asset ${asset.id}: $e');
        continue;
      }
    }

    return catPhotos;
  }

  Future<DetectionResult> _mlDetection(
    img.Image image,
    Stopwatch stopwatch,
  ) async {
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

    // Simple heuristic based on filename
    final fileName = photoPath.toLowerCase();
    final catKeywords = ['cat', 'kitty', 'kitten', 'feline', 'meow'];
    final hasKeyword = catKeywords.any((keyword) => fileName.contains(keyword));

    double confidence = 0.0;
    bool hasCat = false;

    if (hasKeyword) {
      confidence = 0.8;
      hasCat = true;
    } else {
      // Additional basic analysis could go here
      // For now, use a very low threshold to avoid false positives
      confidence = 0.1;
      hasCat = false;
    }

    stopwatch.stop();

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
}
