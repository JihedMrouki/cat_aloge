import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/notifiers/gallery_notifier.dart';
import '../../presentation/state/gallery_state.dart';

// Main gallery provider
final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>(
  (ref) => GalleryNotifier(),
);

// Derived providers for specific data
final photosProvider = Provider<List<CatPhoto>>((ref) {
  return ref.watch(galleryProvider).photos;
});

final favoritePhotosProvider = Provider<List<CatPhoto>>((ref) {
  return ref.watch(galleryProvider).favoritePhotos;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(galleryProvider).isLoading;
});

final hasErrorProvider = Provider<bool>((ref) {
  return ref.watch(galleryProvider).hasError;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(galleryProvider).errorMessage;
});

final photoCountProvider = Provider<int>((ref) {
  return ref.watch(galleryProvider).photos.length;
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(galleryProvider).favoritePhotos.length;
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
