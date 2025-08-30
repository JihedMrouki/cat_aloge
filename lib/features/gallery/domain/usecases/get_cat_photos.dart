import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class GetCatPhotos {
  final GalleryRepository _repository;

  const GetCatPhotos(this._repository);

  Future<List<CatPhoto>> call() async {
    return await _repository.getCatPhotos();
  }
}
