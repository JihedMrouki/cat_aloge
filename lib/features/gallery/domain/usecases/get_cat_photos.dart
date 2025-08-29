import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetCatPhotos {
  final GalleryRepository _repository;

  GetCatPhotos(this._repository);

  Future<List<CatPhoto>> call() async {
    try {
      return await _repository.getCatPhotos();
    } catch (e) {
      throw Exception('Failed to load cat photos: $e');
    }
  }
}

final getCatPhotosProvider = Provider<GetCatPhotos>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return GetCatPhotos(repository);
});
