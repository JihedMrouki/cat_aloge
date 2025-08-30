import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

abstract class FavoritesRepository {
  /// Get all favorite photos
  Future<List<CatPhoto>> getFavoritePhotos();

  /// Add photo to favorites
  Future<void> addToFavorites(String photoId);

  /// Remove photo from favorites
  Future<void> removeFromFavorites(String photoId);

  /// Check if photo is favorite
  Future<bool> isFavorite(String photoId);

  /// Toggle favorite status
  Future<bool> toggleFavorite(String photoId);

  /// Get favorites count
  Future<int> getFavoritesCount();
}
