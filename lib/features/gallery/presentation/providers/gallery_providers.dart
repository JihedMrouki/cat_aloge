import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/get_cat_photos.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/refresh_gallery.dart';
import 'package:cat_aloge/features/permissions/presentation/providers/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_aloge/features/favorites/data/repository/faorites_repository_impl.dart';
import 'package:cat_aloge/features/favorites/domain/usecases/toggle_favorite.dart';

final photoDataSourceProvider = Provider<DevicePhotoDataSource>((ref) {
  final checkPhotoPermissionUseCase = ref.watch(checkPhotoPermissionUseCaseProvider);
  final requestPhotoPermissionUseCase = ref.watch(requestPhotoPermissionUseCaseProvider);
  return DevicePhotoDataSourceImpl(checkPhotoPermissionUseCase, requestPhotoPermissionUseCase);
});

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepositoryImpl(
    photoDataSource: ref.watch(photoDataSourceProvider),
  );
});

final getCatPhotosUsecaseProvider = Provider<GetCatPhotosUseCase>((ref) {
  return GetCatPhotosUseCase(ref.watch(galleryRepositoryProvider));
});

final refreshGalleryUsecaseProvider = Provider<RefreshGalleryUseCase>((ref) {
  return RefreshGalleryUseCase(ref.watch(galleryRepositoryProvider));
});

final photoCountProvider = Provider<int>((ref) {
  return 0; // Placeholder
});

final galleryProvider = StateNotifierProvider<GalleryNotifier, AsyncValue<List<CatPhoto>>>((ref) {
  final toggleFavoriteUseCase = ref.watch(toggleFavoriteUseCaseProvider);
  return GalleryNotifier(
    ref.read(getCatPhotosUsecaseProvider),
    ref.read(refreshGalleryUsecaseProvider),
    toggleFavoriteUseCase,
  );
});

class GalleryNotifier extends StateNotifier<AsyncValue<List<CatPhoto>>> {
  final GetCatPhotosUseCase _getCatPhotosUseCase;
  final RefreshGalleryUseCase _refreshGalleryUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  GalleryNotifier(
    this._getCatPhotosUseCase,
    this._refreshGalleryUseCase,
    this._toggleFavoriteUseCase,
  ) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final photos = await _getCatPhotosUseCase();
      state = AsyncValue.data(photos);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> refreshPhotos() async {
    state = const AsyncValue.loading();
    try {
      await _refreshGalleryUseCase();
      final photos = await _getCatPhotosUseCase();
      state = AsyncValue.data(photos);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> toggleFavorite(String id) async {
    // Persist the change
    await _toggleFavoriteUseCase(id);

    // Update the UI optimistically
    final currentPhotos = state.valueOrNull ?? [];
    final updatedPhotos = currentPhotos.map((photo) {
      if (photo.id == id) {
        return photo.copyWith(isFavorite: !photo.isFavorite);
      }
      return photo;
    }).toList();
    state = AsyncValue.data(updatedPhotos);
  }
}
