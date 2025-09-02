import 'package:cat_aloge/features/favorites/data/datasources/local_favorites_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/mock_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/repository/gallery_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/get_cat_photos.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/refresh_gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoDataSourceProvider = Provider<PhotoDataSource>((ref) {
  return MockPhotoDataSource();
});

final favoritesDataSourceProvider = Provider<FavoritesDataSource>((ref) {
  return LocalFavoritesDataSource();
});

// Repository Providers
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepositoryImpl(
    ref.watch(photoDataSourceProvider),
    ref.watch(favoritesDataSourceProvider),
  );
});

// Use Case Providers
final getCatPhotosUseCaseProvider = Provider<GetCatPhotos>((ref) {
  return GetCatPhotos(ref.watch(galleryRepositoryProvider));
});

final refreshGalleryUseCaseProvider = Provider<RefreshGallery>((ref) {
  return RefreshGallery(ref.watch(galleryRepositoryProvider));
});

// State Notifier Provider
final galleryProvider =
    StateNotifierProvider<GalleryNotifier, AsyncValue<List<CatPhoto>>>((ref) {
      return GalleryNotifier(
        ref.watch(getCatPhotosUseCaseProvider),
        ref.watch(refreshGalleryUseCaseProvider),
        ref.watch(favoritesDataSourceProvider),
      );
    });

// Derived Providers
final photosProvider = Provider<List<CatPhoto>>((ref) {
  return ref.watch(galleryProvider).valueOrNull ?? [];
});

final favoritePhotosProvider = Provider<List<CatPhoto>>((ref) {
  final photos = ref.watch(photosProvider);
  return photos.where((photo) => photo.isFavorite).toList();
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(galleryProvider).isLoading;
});

final hasErrorProvider = Provider<bool>((ref) {
  return ref.watch(galleryProvider).hasError;
});

final errorMessageProvider = Provider<String?>((ref) {
  final asyncValue = ref.watch(galleryProvider);
  return asyncValue.hasError ? asyncValue.error.toString() : null;
});

final photoCountProvider = Provider<int>((ref) {
  return ref.watch(photosProvider).length;
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoritePhotosProvider).length;
});

// Provider for getting a specific photo by ID
final photoByIdProvider = Provider.family<CatPhoto?, String>((ref, photoId) {
  final photos = ref.watch(photosProvider);
  try {
    return photos.firstWhere((photo) => photo.id == photoId);
  } catch (e) {
    return null;
  }
});

// Provider for checking if a photo is favorite
final isPhotoFavoriteProvider = Provider.family<bool, String>((ref, photoId) {
  final photo = ref.watch(photoByIdProvider(photoId));
  return photo?.isFavorite ?? false;
});

// Gallery Notifier Class
class GalleryNotifier extends StateNotifier<AsyncValue<List<CatPhoto>>> {
  final GetCatPhotos _getCatPhotos;
  final RefreshGallery _refreshGallery;
  final FavoritesDataSource _favoritesDataSource;

  GalleryNotifier(
    this._getCatPhotos,
    this._refreshGallery,
    this._favoritesDataSource,
  ) : super(const AsyncValue.loading());

  Future<void> loadPhotos() async {
    state = const AsyncValue.loading();
    try {
      final photos = await _getCatPhotos.call();
      state = AsyncValue.data(photos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPhotos() async {
    try {
      final photos = await _refreshGallery.call();
      state = AsyncValue.data(photos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(String photoId) async {
    final currentPhotos = state.valueOrNull ?? [];

    try {
      // Toggle in data source
      final newFavoriteStatus =
          await (_favoritesDataSource as LocalFavoritesDataSource)
              .toggleFavorite(photoId);

      // Update local state
      final updatedPhotos = currentPhotos.map((photo) {
        if (photo.id == photoId) {
          return photo.copyWith(isFavorite: newFavoriteStatus);
        }
        return photo;
      }).toList();

      state = AsyncValue.data(updatedPhotos);
    } catch (error, stackTrace) {
      // Handle error but don't break the UI
      print('Error toggling favorite: $error');
    }
  }
}
