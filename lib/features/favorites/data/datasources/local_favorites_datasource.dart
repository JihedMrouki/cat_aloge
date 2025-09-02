// lib/features/favorites/data/datasources/local_favorites_datasource.dart

abstract class FavoritesDataSource {
  Future<List<String>> getFavoriteIds();
  Future<void> addFavorite(String photoId);
  Future<void> removeFavorite(String photoId);
  Future<bool> isFavorite(String photoId);
}

class LocalFavoritesDataSource implements FavoritesDataSource {
  // In-memory storage for now (replace with Hive later)
  static final Set<String> _favorites = <String>{};

  @override
  Future<List<String>> getFavoriteIds() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return _favorites.toList();
  }

  @override
  Future<void> addFavorite(String photoId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _favorites.add(photoId);
  }

  @override
  Future<void> removeFavorite(String photoId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _favorites.remove(photoId);
  }

  @override
  Future<bool> isFavorite(String photoId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _favorites.contains(photoId);
  }

  // Method to toggle favorite status
  Future<bool> toggleFavorite(String photoId) async {
    if (_favorites.contains(photoId)) {
      await removeFavorite(photoId);
      return false;
    } else {
      await addFavorite(photoId);
      return true;
    }
  }

  // Method to clear all favorites (useful for testing)
  Future<void> clearAll() async {
    _favorites.clear();
  }
}
