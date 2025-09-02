import 'dart:io';

import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/data/datasources/ml_detection_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class LocalPhotoDataSource {
  Future<List<CatPhoto>> getCatPhotos();
  Future<void> refreshPhotos();
  Future<void> clearCache();
}

class LocalPhotoDataSourceImpl implements LocalPhotoDataSource {
  final MlDetectionDataSource _mlDataSource;
  final List<CatPhoto> _cachedPhotos = [];
  bool _isInitialized = false;

  LocalPhotoDataSourceImpl(this._mlDataSource);

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    try {
      if (!_isInitialized) {
        await _initialize();
      }

      // Return cached results if available
      if (_cachedPhotos.isNotEmpty) {
        AppLogger.info('Returning ${_cachedPhotos.length} cached cat photos');
        return List.from(_cachedPhotos);
      }

      return await _scanDeviceForCatPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> refreshPhotos() async {
    AppLogger.info('Refreshing cat photos from device');
    _cachedPhotos.clear();
    await getCatPhotos();
  }

  @override
  Future<void> clearCache() async {
    AppLogger.info('Clearing photo cache');
    _cachedPhotos.clear();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing local photo data source...');

      // Initialize ML detection
      await _mlDataSource.initialize();

      _isInitialized = true;
      AppLogger.info('Local photo data source initialized');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize local photo data source',
        e,
        stackTrace,
      );
      rethrow;
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
    );

    if (albums.isEmpty) {
      AppLogger.warning('No photo albums found');
      return [];
    }

    // Get photos from main album
    final AssetPathEntity mainAlbum = albums.first;
    final int photoCount = await mainAlbum.assetCountAsync;

    AppLogger.info('Found $photoCount total photos in device');

    // Process photos in batches
    const int batchSize = 50;
    final List<CatPhoto> allCatPhotos = [];

    for (int start = 0; start < photoCount; start += batchSize) {
      final int end = (start + batchSize > photoCount)
          ? photoCount
          : start + batchSize;

      AppLogger.info('Processing photos $start-$end of $photoCount');

      final List<AssetEntity> batch = await mainAlbum.getAssetListRange(
        start: start,
        end: end,
      );

      final List<CatPhoto> batchCatPhotos = await _processBatch(batch);
      allCatPhotos.addAll(batchCatPhotos);

      // Update progress and give UI time to breathe
      AppLogger.debug('Batch complete: ${batchCatPhotos.length} cats found');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Cache the results
    _cachedPhotos.clear();
    _cachedPhotos.addAll(allCatPhotos);

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
        final DetectionResult detection = await _mlDataSource.detectCatInPhoto(
          file.path,
        );

        if (detection.hasCat) {
          final catPhoto = CatPhoto.fromDevicePhoto(
            id: asset.id,
            path: file.path,
            fileName:
                asset.title ?? 'IMG_${DateTime.now().millisecondsSinceEpoch}',
            dateAdded: asset.createDateTime,
            sizeBytes: asset.size,
            width: asset.width,
            height: asset.height,
            detectionResult: detection,
            lastModified: asset.modifiedDateTime,
            mimeType: asset.mimeType,
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

  void dispose() {
    AppLogger.info('Disposing local photo data source');
    _mlDataSource.dispose();
    _cachedPhotos.clear();
    _isInitialized = false;
  }
}
