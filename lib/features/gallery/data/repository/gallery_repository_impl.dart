import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/ml_detection_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final DevicePhotoDataSource _devicePhotoDataSource;
  final MlDetectionDataSource _mlDetectionDataSource;
  final Map<String, DetectionResult> _detectionCache = {};
  final Map<String, bool> _favoriteCache = {};

  GalleryRepositoryImpl(
    this._devicePhotoDataSource,
    this._mlDetectionDataSource,
  );

  @override
  Future<List<CatPhoto>> getDeviceCatPhotos() async {
    try {
      AppLogger.info('Fetching device cat photos...');

      final photos = await _devicePhotoDataSource.getDeviceCatPhotos();

      // Apply favorite status from cache
      final updatedPhotos = photos.map((photo) {
        final isFavorite = _favoriteCache[photo.id] ?? photo.isFavorite;
        return photo.copyWith(isFavorite: isFavorite);
      }).toList();

      AppLogger.info(
        'Retrieved ${updatedPhotos.length} cat photos from device',
      );
      return updatedPhotos;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching device cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DetectionResult> detectCatInPhoto(String photoPath) async {
    try {
      // Check cache first
      if (_detectionCache.containsKey(photoPath)) {
        AppLogger.debug('Using cached detection result for $photoPath');
        return _detectionCache[photoPath]!;
      }

      // Perform detection
      final result = await _mlDetectionDataSource.detectCatInPhoto(photoPath);

      // Cache the result
      _detectionCache[photoPath] = result;

      AppLogger.debug(
        'Detection completed for $photoPath: '
        '${result.hasCat ? 'CAT' : 'NO CAT'} '
        '(${(result.confidence * 100).toStringAsFixed(1)}%)',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error detecting cat in photo: $photoPath',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<DetectionResult>> detectCatsInBatch(
    List<String> photoPaths,
  ) async {
    try {
      AppLogger.info(
        'Starting batch detection for ${photoPaths.length} photos',
      );

      final results = await _mlDetectionDataSource.detectCatsInBatch(
        photoPaths,
      );

      // Cache all results
      for (int i = 0; i < photoPaths.length && i < results.length; i++) {
        _detectionCache[photoPaths[i]] = results[i];
      }

      final catsFound = results.where((r) => r.hasCat).length;
      AppLogger.info('Batch detection completed: $catsFound cats found');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Error in batch cat detection', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> refreshGallery() async {
    try {
      AppLogger.info('Refreshing gallery...');

      // Clear caches
      await clearCache();

      // Refresh device photos
      await _devicePhotoDataSource.refreshPhotos();

      AppLogger.info('Gallery refresh completed');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing gallery', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      AppLogger.info('Clearing detection cache...');

      _detectionCache.clear();
      // Note: Don't clear favorite cache as it represents user preferences

      AppLogger.info('Cache cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing cache', e, stackTrace);
    }
  }

  @override
  Future<CatPhoto> toggleFavorite(String photoId) async {
    try {
      AppLogger.debug('Toggling favorite status for photo: $photoId');

      // Get current photos to find the specific one
      final photos = await getDeviceCatPhotos();
      final photo = photos.firstWhere(
        (p) => p.id == photoId,
        orElse: () => throw Exception('Photo not found: $photoId'),
      );

      // Toggle favorite status
      final updatedPhoto = photo.toggleFavorite();

      // Update cache
      _favoriteCache[photoId] = updatedPhoto.isFavorite;

      AppLogger.debug(
        'Photo $photoId favorite status: ${updatedPhoto.isFavorite ? 'ADDED' : 'REMOVED'}',
      );

      return updatedPhoto;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error toggling favorite for photo: $photoId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<CatPhoto>> getFavoriteCatPhotos() async {
    try {
      final allPhotos = await getDeviceCatPhotos();
      final favoritePhotos = allPhotos
          .where((photo) => photo.isFavorite)
          .toList();

      AppLogger.info('Retrieved ${favoritePhotos.length} favorite cat photos');
      return favoritePhotos;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting favorite cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveDetectionResult(
    String photoPath,
    DetectionResult result,
  ) async {
    try {
      _detectionCache[photoPath] = result;
      AppLogger.debug('Saved detection result for $photoPath');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving detection result', e, stackTrace);
    }
  }

  @override
  Future<DetectionResult?> getCachedDetectionResult(String photoPath) async {
    try {
      final result = _detectionCache[photoPath];
      if (result != null) {
        AppLogger.debug('Retrieved cached detection result for $photoPath');
      }
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting cached detection result', e, stackTrace);
      return null;
    }
  }

  void dispose() {
    AppLogger.info('Disposing gallery repository');
    _detectionCache.clear();
    _favoriteCache.clear();
    _mlDetectionDataSource.dispose();
  }
}
