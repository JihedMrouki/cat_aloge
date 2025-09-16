import 'package:cat_aloge/features/favorites/data/datasources/hive_favorites_datasource.dart';
import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cat_aloge/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/datasources/photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/permissions/presentation/providers/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final HiveFavoritesDataSource _favoritesDataSource;
  final PhotoDataSource _photoDataSource;

  const FavoritesRepositoryImpl(
    this._favoritesDataSource,
    this._photoDataSource,
  );

  @override
  Future<List<CatPhoto>> getFavoritePhotos() async {
    final allPhotos = await _photoDataSource.getCatPhotos();
    final favoriteIds = await _favoritesDataSource.getFavoriteIds();
    final favoriteIdsSet = Set<String>.from(favoriteIds);

    return allPhotos
        .where((photo) => favoriteIdsSet.contains(photo.id))
        .map((photo) => photo.copyWith(isFavorite: true))
        .toList();
  }

  @override
  Future<void> addToFavorites(String photoId) async {
    await _favoritesDataSource.addFavorite(photoId);
  }

  @override
  Future<void> removeFromFavorites(String photoId) async {
    await _favoritesDataSource.removeFavorite(photoId);
  }

  @override
  Future<bool> isFavorite(String photoId) async {
    return await _favoritesDataSource.isFavorite(photoId);
  }

  @override
  Future<bool> toggleFavorite(String photoId) async {
    // The Hive data source already has a toggle method
    return await _favoritesDataSource.toggleFavorite(photoId);
  }

  @override
  Future<int> getFavoritesCount() async {
    final favoriteIds = await _favoritesDataSource.getFavoriteIds();
    return favoriteIds.length;
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final favoritesDataSource = ref.watch(favoritesDataSourceProvider);
  final photoDataSource = ref.watch(photoDataSourceProvider);
  return FavoritesRepositoryImpl(favoritesDataSource, photoDataSource);
});

final favoritesDataSourceProvider = Provider<HiveFavoritesDataSource>((ref) {
  return HiveFavoritesDataSource();
});

final photoDataSourceProvider = Provider<PhotoDataSource>((ref) {
  final checkPhotoPermissionUseCase = ref.watch(checkPhotoPermissionUseCaseProvider);
  final requestPhotoPermissionUseCase = ref.watch(requestPhotoPermissionUseCaseProvider);
  return DevicePhotoDataSourceImpl(checkPhotoPermissionUseCase, requestPhotoPermissionUseCase);
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return ToggleFavoriteUseCase(repository);
});