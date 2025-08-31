import 'package:cat_aloge/features/favorites/data/datasources/local_favorites_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/mock_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final PhotoDataSource _photoDataSource;
  final FavoritesDataSource _favoritesDataSource;

  const GalleryRepositoryImpl(this._photoDataSource, this._favoritesDataSource);

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    final photos = await _photoDataSource.getPhotos();
    final favoriteIds = await _favoritesDataSource.getFavoriteIds();
    final favoriteIdsSet = Set<String>.from(favoriteIds);

    // Map to domain entities and update favorite status
    return photos.map((photoModel) {
      return photoModel
          .copyWith(isFavorite: favoriteIdsSet.contains(photoModel.id))
          .toEntity();
    }).toList();
  }

  @override
  Future<DetectionResult> detectCatsInPhoto(String photoPath) async {
    final result = await _photoDataSource.detectCat(photoPath);
    return DetectionResult(
      confidence: result.confidence,
      hasCat: result.hasCat,
      boundingBoxes: result.boundingBoxes,
      breed: result.breed,
    );
  }

  @override
  Future<List<CatPhoto>> refreshPhotos() async {
    final photos = await _photoDataSource.refreshPhotos();
    final favoriteIds = await _favoritesDataSource.getFavoriteIds();
    final favoriteIdsSet = Set<String>.from(favoriteIds);

    return photos.map((photoModel) {
      return photoModel
          .copyWith(isFavorite: favoriteIdsSet.contains(photoModel.id))
          .toEntity();
    }).toList();
  }

  @override
  Future<List<CatPhoto>> getPhotosPage({int page = 0, int limit = 20}) async {
    final allPhotos = await getCatPhotos();
    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, allPhotos.length);

    if (startIndex >= allPhotos.length) {
      return [];
    }

    return allPhotos.sublist(startIndex, endIndex);
  }
}
