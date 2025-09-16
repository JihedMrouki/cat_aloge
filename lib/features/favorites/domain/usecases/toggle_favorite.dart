import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<bool> call(String photoId) async {
    return await _repository.toggleFavorite(photoId);
  }
}
