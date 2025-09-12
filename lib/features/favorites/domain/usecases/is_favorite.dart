import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/faorites_repository_impl.dart';

class IsFavorite {
  final FavoritesRepository _repository;

  IsFavorite(this._repository);

  Future<bool> call(String catPhotoId) async {
    try {
      return await _repository.isFavorite(catPhotoId);
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }
}

final isFavoriteProvider = Provider<IsFavorite>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return IsFavorite(repository);
});
