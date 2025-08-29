import 'package:cat_aloge/features/favorites/domain/entities/favorite_cat.dart';
import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddToFavorites {
  final FavoritesRepository _repository;

  AddToFavorites(this._repository);

  Future<void> call(FavoriteCat favoriteCat) async {
    try {
      await _repository.addToFavorites(favoriteCat);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }
}

final addToFavoritesProvider = Provider<AddToFavorites>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return AddToFavorites(repository);
});
