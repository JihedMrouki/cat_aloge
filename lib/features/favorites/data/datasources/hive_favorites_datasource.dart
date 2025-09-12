// lib/features/favorites/data/datasources/hive_favorites_datasource.dart
import 'package:cat_aloge/features/favorites/data/datasources/local_favorites_datasource.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveFavoritesDataSource implements FavoritesDataSource {
  static const String _boxName = 'favorites';
  static const String _favoritesKey = 'favorite_photo_ids';
  Box<dynamic>? _box;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Box<dynamic> get _favoritesBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'Favorites box is not initialized. Call initialize() first.',
      );
    }
    return _box!;
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    try {
      final favoriteIds = _favoritesBox.get(
        _favoritesKey,
        defaultValue: <String>[],
      );
      return List<String>.from(favoriteIds);
    } catch (e) {
      return <String>[];
    }
  }

  @override
  Future<void> addFavorite(String photoId) async {
    try {
      final currentFavorites = await getFavoriteIds();
      if (!currentFavorites.contains(photoId)) {
        currentFavorites.add(photoId);
        await _favoritesBox.put(_favoritesKey, currentFavorites);
      }
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String photoId) async {
    try {
      final currentFavorites = await getFavoriteIds();
      currentFavorites.remove(photoId);
      await _favoritesBox.put(_favoritesKey, currentFavorites);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(String photoId) async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.contains(photoId);
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status and return new status
  Future<bool> toggleFavorite(String photoId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(photoId);
      if (isCurrentlyFavorite) {
        await removeFavorite(photoId);
        return false;
      } else {
        await addFavorite(photoId);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.length;
    } catch (e) {
      return 0;
    }
  }

  // Clear all favorites (useful for testing/reset)
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesBox.put(_favoritesKey, <String>[]);
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  // Export favorites (for backup/sync)
  Future<Map<String, dynamic>> exportFavorites() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return {
        'favorites': favoriteIds,
        'count': favoriteIds.length,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  // Import favorites (for backup/sync)
  Future<void> importFavorites(List<String> favoriteIds) async {
    try {
      await _favoritesBox.put(_favoritesKey, favoriteIds);
    } catch (e) {
      throw Exception('Failed to import favorites: $e');
    }
  }

  // Close the box when done
  Future<void> dispose() async {
    if (_box?.isOpen == true) {
      await _box!.close();
    }
  }
}

// Fallback in-memory implementation for testing/development
class InMemoryFavoritesDataSource implements FavoritesDataSource {
  static final Set<String> _favorites = <String>{};

  @override
  Future<void> initialize() async {
    // No initialization needed for in-memory storage
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    await Future.delayed(const Duration(milliseconds: 50));
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

  Future<bool> toggleFavorite(String photoId) async {
    if (_favorites.contains(photoId)) {
      await removeFavorite(photoId);
      return false;
    } else {
      await addFavorite(photoId);
      return true;
    }
  }
}