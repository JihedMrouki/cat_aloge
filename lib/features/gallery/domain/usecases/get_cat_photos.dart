import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repositories/gallery_repository.dart';

class GetCatPhotosUseCase {
  final GalleryRepository _repository;

  GetCatPhotosUseCase(this._repository);

  Future<List<CatPhoto>> call() async {
    return await _repository.getCatPhotos();
  }
}