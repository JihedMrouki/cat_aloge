import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoveFromFavorites {
  final FavoritesRepository _repository;

  RemoveFromFavorites(this._repository);

  Future<void> call(String catPhotoId) async {
    try {
      await _repository.removeFromFavorites(catPhotoId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
}

final removeFromFavoritesProvider = Provider<RemoveFromFavorites>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return RemoveFromFavorites(repository);
});
