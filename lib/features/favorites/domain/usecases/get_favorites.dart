import 'package:cat_aloge/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

class GetFavorites {
  final FavoritesRepository _repository;

  const GetFavorites(this._repository);

  Future<List<CatPhoto>> call() async {
    return await _repository.getFavoritePhotos();
  }
}

class GetFavoritesCount {
  final FavoritesRepository _repository;

  const GetFavoritesCount(this._repository);

  Future<int> call() async {
    return await _repository.getFavoritesCount();
  }
}
