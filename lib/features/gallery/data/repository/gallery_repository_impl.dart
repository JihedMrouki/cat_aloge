import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/data/datasources/local_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/ml_detection_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final LocalPhotoDataSource _localDataSource;
  final MlDetectionDataSource _mlDataSource;

  GalleryRepositoryImpl(this._localDataSource, this._mlDataSource);

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    try {
      AppLogger.info('Repository: Getting cat photos...');

      final catPhotos = await _localDataSource.getCatPhotos();

      // Sort by detection confidence and date
      catPhotos.sort((a, b) {
        // First sort by confidence (higher confidence first)
        final confidenceCompare = (b.detectionResult?.confidence ?? 0.0)
            .compareTo(a.detectionResult?.confidence ?? 0.0);

        if (confidenceCompare != 0) return confidenceCompare;

        // Then sort by date (newer first)
        return b.dateAdded.compareTo(a.dateAdded);
      });

      AppLogger.info('Repository: Returning ${catPhotos.length} cat photos');
      return catPhotos;
    } catch (e, stackTrace) {
      AppLogger.error('Repository error getting cat photos', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> refreshGallery() async {
    try {
      AppLogger.info('Repository: Refreshing gallery...');
      await _localDataSource.refreshPhotos();
      AppLogger.info('Repository: Gallery refresh complete');
    } catch (e, stackTrace) {
      AppLogger.error('Repository error refreshing gallery', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DetectionResult> detectCatInPhoto(String photoPath) async {
    try {
      return await _mlDataSource.detectCatInPhoto(photoPath);
    } catch (e, stackTrace) {
      AppLogger.error('Repository error detecting cat in photo', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      AppLogger.info('Repository: Clearing cache...');
      await _localDataSource.clearCache();
    } catch (e, stackTrace) {
      AppLogger.error('Repository error clearing cache', e, stackTrace);
      rethrow;
    }
  }

  void dispose() {
    AppLogger.info('Disposing gallery repository');
    _localDataSource.dispose();
  }
}
