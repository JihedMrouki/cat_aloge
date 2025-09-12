import 'package:cat_aloge/features/favorites/data/datasources/local_favorites_datasource.dart';
import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PhotoDataSource {
  Future<List<CatPhoto>> getPhotos();
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDataSource _favoritesDataSource;
  final PhotoDataSource _photoDataSource;

  const FavoritesRepositoryImpl(
    this._favoritesDataSource,
    this._photoDataSource,
  );

  @override
  Future<List<CatPhoto>> getFavoritePhotos() async {
    final allPhotos = await _photoDataSource.getPhotos();
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
    final currentlyFavorite = await _favoritesDataSource.isFavorite(photoId);

    if (currentlyFavorite) {
      await _favoritesDataSource.removeFavorite(photoId);
      return false;
    } else {
      await _favoritesDataSource.addFavorite(photoId);
      return true;
    }
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

final favoritesDataSourceProvider = Provider<FavoritesDataSource>((ref) {
  return LocalFavoritesDataSource();
});

final photoDataSourceProvider = Provider<PhotoDataSource>((ref) {
  // This should be implemented in the gallery feature
  throw UnimplementedError();
});
