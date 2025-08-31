abstract class FavoritesDataSource {
  Future<List<String>> getFavoriteIds();
  Future<void> addFavorite(String photoId);
  Future<void> removeFavorite(String photoId);
  Future<bool> isFavorite(String photoId);
  Future<void> clearFavorites();
}

class InMemoryFavoritesDataSource implements FavoritesDataSource {
  static final Set<String> _favoriteIds = {};

  @override
  Future<List<String>> getFavoriteIds() async {
    return List.from(_favoriteIds);
  }

  @override
  Future<void> addFavorite(String photoId) async {
    _favoriteIds.add(photoId);
  }

  @override
  Future<void> removeFavorite(String photoId) async {
    _favoriteIds.remove(photoId);
  }

  @override
  Future<bool> isFavorite(String photoId) async {
    return _favoriteIds.contains(photoId);
  }

  @override
  Future<void> clearFavorites() async {
    _favoriteIds.clear();
  }
}
