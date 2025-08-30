import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

abstract class GalleryRepository {
  /// Get all cat photos from the device
  Future<List<CatPhoto>> getCatPhotos();

  /// Detect cats in a specific photo
  Future<DetectionResult> detectCatsInPhoto(String photoPath);

  /// Refresh the photo gallery
  Future<List<CatPhoto>> refreshPhotos();

  /// Get photos with pagination
  Future<List<CatPhoto>> getPhotosPage({int page = 0, int limit = 20});
}
