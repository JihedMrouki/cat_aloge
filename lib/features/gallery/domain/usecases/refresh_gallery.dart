import 'package:cat_aloge/features/gallery/domain/repositories/gallery_repository.dart';

class RefreshGalleryUseCase {
  final GalleryRepository _repository;

  RefreshGalleryUseCase(this._repository);

  Future<void> call() async {
    return await _repository.refreshPhotos();
  }
}