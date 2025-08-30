import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';

class AddToFavorites {
  final FavoritesRepository _repository;

  const AddToFavorites(this._repository);

  Future<bool> call(String photoId) async {
    return await _repository.toggleFavorite(photoId);
  }
}
