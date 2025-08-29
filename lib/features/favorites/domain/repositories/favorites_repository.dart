import 'package:cat_aloge/features/favorites/domain/entities/favorite_cat.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteCat>> getFavorites();
  Future<void> addToFavorites(FavoriteCat favoriteCat);
  Future<void> removeFromFavorites(String catPhotoId);
  Future<bool> isFavorite(String catPhotoId);
  Future<void> clearFavorites();
}
