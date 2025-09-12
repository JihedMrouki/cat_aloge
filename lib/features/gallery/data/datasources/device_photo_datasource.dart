import 'dart:io';
import 'dart:typed_data';

import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/check_photo_permission.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/request_photo_permission.dart';
import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';

abstract class DevicePhotoDataSource {
  Future<List<CatPhoto>> getCatPhotos();
  Future<void> refreshPhotos();
  Future<void> clearCache();
  void dispose();
}

class DevicePhotoDataSourceImpl implements DevicePhotoDataSource {
  final CheckPhotoPermissionUseCase _checkPhotoPermissionUseCase;
  final RequestPhotoPermissionUseCase _requestPhotoPermissionUseCase;
  Interpreter? _interpreter;
  final bool _isModelLoaded = false;
  final List<CatPhoto> _cachedCatPhotos = [];
  bool _isScanning = false;

  DevicePhotoDataSourceImpl(
    this._checkPhotoPermissionUseCase,
    this._requestPhotoPermissionUseCase,
  ) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      AppLogger.info('Initializing device photo data source...');
      await _ensureModelLoaded();
      AppLogger.info('Device photo data source initialized');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize device photo data source',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    if (_isScanning) {
      AppLogger.warning('Scan already in progress, returning cached results.');
      return List.from(_cachedCatPhotos);
    }

    try {
      if (_cachedCatPhotos.isNotEmpty) {
        AppLogger.info(
          'Returning ${_cachedCatPhotos.length} cached cat photos',
        );
        return List.from(_cachedCatPhotos);
      }
      return await _scanDeviceForCatPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> refreshPhotos() async {
    AppLogger.info('Refreshing device photos...');
    await clearCache();
  }

  @override
  Future<void> clearCache() async {
    AppLogger.info('Clearing photo cache');
    _cachedCatPhotos.clear();
  }

  @override
  void dispose() {
    _interpreter?.close();
    AppLogger.info('Device photo data source disposed');
  }

  Future<DetectionResult> _detectCatInPhoto(File imageFile) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (!_isModelLoaded || _interpreter == null) {
        return await _heuristicDetection(imageFile.path, stopwatch);
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) throw Exception('Could not decode image.');

      return await _mlDetection(image, stopwatch);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error detecting cat in photo: ${imageFile.path}',
        e,
        stackTrace,
      );
      return DetectionResult(
        hasCat: false,
        confidence: 0.0,
        boundingBoxes: [],
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  Future<List<CatPhoto>> _scanDeviceForCatPhotos() async {
    _isScanning = true;
    AppLogger.info('Starting device scan for cat photos...');

    try {
      final permissionState = await _checkPhotoPermissionUseCase();
      if (permissionState.status == PhotoPermissionStatus.denied ||
          permissionState.status == PhotoPermissionStatus.permanentlyDenied) {
        final requestedPermissionState = await _requestPhotoPermissionUseCase();
        if (!requestedPermissionState.isGranted) {
          throw Exception('Photo permission not granted');
        }
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isEmpty) return [];

      final allPhotosAlbum = albums.first;
      final totalPhotos = await allPhotosAlbum.assetCountAsync;
      AppLogger.info('Found $totalPhotos total photos on device.');

      const batchSize = 50;
      final List<CatPhoto> allCatPhotos = [];

      for (int i = 0; i < totalPhotos; i += batchSize) {
        final assets = await allPhotosAlbum.getAssetListRange(
          start: i,
          end: i + batchSize,
        );
        final batchResult = await _processBatch(assets);
        allCatPhotos.addAll(batchResult);
      }

      _cachedCatPhotos.clear();
      _cachedCatPhotos.addAll(allCatPhotos);
      AppLogger.info(
        'Device scan complete: Found ${allCatPhotos.length} cat photos.',
      );
      return List.from(allCatPhotos);
    } finally {
      _isScanning = false;
    }
  }

  Future<List<CatPhoto>> _processBatch(List<AssetEntity> assets) async {
    final List<CatPhoto> batchCatPhotos = [];
    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;

      final detectionResult = await _detectCatInPhoto(file);
      if (detectionResult.hasCat) {
        batchCatPhotos.add(
          CatPhoto(
            id: asset.id,
            path: file.path,
            fileName: asset.title ?? 'Unknown',
            dateAdded: asset.createDateTime,
            sizeBytes: await file.length(),
            width: asset.width,
            height: asset.height,
            detectionResult: detectionResult,
          ),
        );
      }
    }
    return batchCatPhotos;
  }

  Future<void> _ensureModelLoaded() async {
    // TODO: implement _ensureModelLoaded
  }

  Future<DetectionResult> _heuristicDetection(
      String path, Stopwatch stopwatch) async {
    // TODO: implement _heuristicDetection
    return DetectionResult(
        hasCat: false,
        confidence: 0.0,
        boundingBoxes: [],
        processingTimeMs: stopwatch.elapsedMilliseconds);
  }

  Future<DetectionResult> _mlDetection(
      img.Image image, Stopwatch stopwatch) async {
    // TODO: implement _mlDetection
    return DetectionResult(
        hasCat: false,
        confidence: 0.0,
        boundingBoxes: [],
        processingTimeMs: stopwatch.elapsedMilliseconds);
  }
}