import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/favorite_cat_model.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/errors/exceptions.dart';

abstract class LocalFavoritesDataSource {
  Future<List<FavoriteCatModel>> getFavorites();
  Future<void> addFavorite(FavoriteCatModel favorite);
  Future<void> removeFavorite(String catPhotoId);
  Future<bool> isFavorite(String catPhotoId);
  Future<void> clearFavorites();
}

class LocalFavoritesDataSourceImpl implements LocalFavoritesDataSource {
  Box<FavoriteCatModel> get _box =>
      Hive.box<FavoriteCatModel>(HiveBoxes.favorites);

  @override
  Future<List<FavoriteCatModel>> getFavorites() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw StorageException('Failed to get favorites: $e');
    }
  }

  @override
  Future<void> addFavorite(FavoriteCatModel favorite) async {
    try {
      await _box.put(favorite.catPhotoId, favorite);
    } catch (e) {
      throw StorageException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String catPhotoId) async {
    try {
      await _box.delete(catPhotoId);
    } catch (e) {
      throw StorageException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(String catPhotoId) async {
    try {
      return _box.containsKey(catPhotoId);
    } catch (e) {
      throw StorageException('Failed to check favorite status: $e');
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await _box.clear();
    } catch (e) {
      throw StorageException('Failed to clear favorites: $e');
    }
  }
}

final localFavoritesDataSourceProvider = Provider<LocalFavoritesDataSource>((
  ref,
) {
  return LocalFavoritesDataSourceImpl();
});
