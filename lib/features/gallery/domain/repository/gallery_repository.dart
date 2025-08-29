import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

abstract class GalleryRepository {
  Future<List<CatPhoto>> getCatPhotos();
  Future<List<CatPhoto>> refreshCatPhotos();
  Future<DetectionResult> detectCatsInPhoto(String imagePath);
  Future<void> clearCache();
}
