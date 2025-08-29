import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite_cat.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local_favorites_datasource.dart';
import '../models/favorite_cat_model.dart';
import '../../../../core/errors/exceptions.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final LocalFavoritesDataSource _localDataSource;

  FavoritesRepositoryImpl(this._localDataSource);

  @override
  Future<List<FavoriteCat>> getFavorites() async {
    try {
      final favoriteModels = await _localDataSource.getFavorites();
      return favoriteModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw StorageException('Failed to get favorites: $e');
    }
  }

  @override
  Future<void> addToFavorites(FavoriteCat favoriteCat) async {
    try {
      final model = FavoriteCatModel.fromEntity(favoriteCat);
      await _localDataSource.addFavorite(model);
    } catch (e) {
      throw StorageException('Failed to add to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String catPhotoId) async {
    try {
      await _localDataSource.removeFavorite(catPhotoId);
    } catch (e) {
      throw StorageException('Failed to remove from favorites: $e');
    }
  }

  @override
  Future<bool> isFavorite(String catPhotoId) async {
    try {
      return await _localDataSource.isFavorite(catPhotoId);
    } catch (e) {
      throw StorageException('Failed to check favorite status: $e');
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await _localDataSource.clearFavorites();
    } catch (e) {
      throw StorageException('Failed to clear favorites: $e');
    }
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final localDataSource = ref.read(localFavoritesDataSourceProvider);
  return FavoritesRepositoryImpl(localDataSource);
});
