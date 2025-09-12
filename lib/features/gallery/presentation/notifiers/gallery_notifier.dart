import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cat_photo.dart';
import '../providers/gallery_providers.dart';

class GalleryNotifier extends AsyncNotifier<List<CatPhoto>> {
  @override
  Future<List<CatPhoto>> build() async {
    return ref.watch(getCatPhotosUsecaseProvider)();
  }

  Future<void> refreshPhotos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref.read(refreshGalleryUsecaseProvider)();
    });
  }

  Future<void> toggleFavorite(String photoId) async {
    final currentPhotos = state.value ?? [];
    final updatedPhotos = currentPhotos.map((photo) {
      if (photo.id == photoId) {
        return photo.copyWith(isFavorite: !photo.isFavorite);
      }
      return photo;
    }).toList();
    state = AsyncValue.data(updatedPhotos);
  }
}
