import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/repository/gallery_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/get_cat_photos.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/refresh_gallery.dart';
import 'package:cat_aloge/features/gallery/presentation/notifiers/gallery_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/check_photo_permission.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/request_photo_permission.dart';
import 'package:cat_aloge/features/permissions/views/providers/permission_providers.dart';

// --- DATA LAYER PROVIDERS ---

// Datasource Provider (Singleton)
final devicePhotoDataSourceProvider = Provider<DevicePhotoDataSource>((ref) {
  final checkPhotoPermissionUseCase = ref.watch(checkPhotoPermissionUseCaseProvider);
  final requestPhotoPermissionUseCase = ref.watch(requestPhotoPermissionUseCaseProvider);
  return DevicePhotoDataSourceImpl(
    checkPhotoPermissionUseCase,
    requestPhotoPermissionUseCase,
  );
});

// Repository Provider
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final dataSource = ref.watch(devicePhotoDataSourceProvider);
  return GalleryRepositoryImpl(dataSource);
});

// --- DOMAIN LAYER (USECASES) PROVIDERS ---

final getCatPhotosUsecaseProvider = Provider<GetCatPhotos>((ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  return GetCatPhotos(repository);
});

final refreshGalleryUsecaseProvider = Provider<RefreshGallery>((ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  return RefreshGallery(repository);
});

// --- PRESENTATION LAYER (STATE NOTIFIER) PROVIDER ---

final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, List<CatPhoto>>(GalleryNotifier.new);

// --- DERIVED PROVIDERS (SELECTORS) FOR UI ---

/// Provides just the list of photos from the main gallery provider.
final photosProvider = Provider<List<CatPhoto>>((ref) {
  return ref.watch(galleryProvider).asData?.value ?? [];
});

/// Provides the total count of cat photos.
final photoCountProvider = Provider<int>((ref) {
  return ref.watch(photosProvider).length;
});

/// Provides the count of favorite photos.
final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(photosProvider).where((p) => p.isFavorite).length;
});
