import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

abstract class GalleryRepository {
  /// Get all cat photos from device storage
  Future<List<CatPhoto>> getDeviceCatPhotos();

  /// Detect cats in a specific photo
  Future<DetectionResult> detectCatInPhoto(String photoPath);

  /// Detect cats in multiple photos (batch processing)
  Future<List<DetectionResult>> detectCatsInBatch(List<String> photoPaths);

  /// Refresh the photo gallery (re-scan device)
  Future<void> refreshGallery();

  /// Clear cached detection results
  Future<void> clearCache();

  /// Toggle favorite status for a photo
  Future<CatPhoto> toggleFavorite(String photoId);

  /// Get favorite cat photos only
  Future<List<CatPhoto>> getFavoriteCatPhotos();

  /// Save detection result to cache
  Future<void> saveDetectionResult(String photoPath, DetectionResult result);

  /// Get cached detection result
  Future<DetectionResult?> getCachedDetectionResult(String photoPath);
}
