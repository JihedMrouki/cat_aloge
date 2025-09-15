import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

abstract class PhotoDataSource {
  Future<List<CatPhoto>> getCatPhotos();
}
