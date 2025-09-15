import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

abstract class GalleryRepository {
  Future<List<CatPhoto>> getCatPhotos();
  Future<void> refreshPhotos();
}
