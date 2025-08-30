import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class RefreshGallery {
  final GalleryRepository _repository;

  const RefreshGallery(this._repository);

  Future<List<CatPhoto>> call() async {
    return await _repository.refreshPhotos();
  }
}
