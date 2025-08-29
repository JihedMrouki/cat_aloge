import 'package:cat_aloge/features/favorites/domain/entities/favorite_cat.dart';
import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetFavorites {
  final FavoritesRepository _repository;

  GetFavorites(this._repository);

  Future<List<FavoriteCat>> call() async {
    try {
      return await _repository.getFavorites();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }
}

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return GetFavorites(repository);
});
