import 'package:cat_aloge/features/favorites/data/datasources/hive_favorites_datasource.dart';
import 'package:cat_aloge/features/favorites/data/repository/faorites_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/datasources/photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_repository_impl_test.mocks.dart';

@GenerateMocks([HiveFavoritesDataSource, PhotoDataSource])
void main() {
  late FavoritesRepositoryImpl repository;
  late MockHiveFavoritesDataSource mockFavoritesDataSource;
  late MockPhotoDataSource mockPhotoDataSource;

  setUp(() {
    mockFavoritesDataSource = MockHiveFavoritesDataSource();
    mockPhotoDataSource = MockPhotoDataSource();
    repository = FavoritesRepositoryImpl(
      mockFavoritesDataSource,
      mockPhotoDataSource,
    );
  });

  // Add dummy creationDate and fileSize
  final tPhoto1 = CatPhoto(id: '1', path: 'path1', fileName: 'file1', isFavorite: false, creationDate: DateTime(2023, 1, 1), fileSize: 100);
  final tPhoto2 = CatPhoto(id: '2', path: 'path2', fileName: 'file2', isFavorite: false, creationDate: DateTime(2023, 1, 2), fileSize: 200);
  final tPhoto3 = CatPhoto(id: '3', path: 'path3', fileName: 'file3', isFavorite: false, creationDate: DateTime(2023, 1, 3), fileSize: 300);
  final tAllPhotos = [tPhoto1, tPhoto2, tPhoto3];

  group('getFavoritePhotos', () {
    test(
      'should return only favorite photos',
      () async {
        // arrange
        when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => tAllPhotos);
        when(mockFavoritesDataSource.getFavoriteIds()).thenAnswer((_) async => ['1', '3']);

        // act
        final result = await repository.getFavoritePhotos();

        // assert
        expect(result.length, 2);
        expect(result.map((p) => p.id), containsAll(['1', '3']));
        expect(result[0].isFavorite, isTrue);
        verify(mockPhotoDataSource.getCatPhotos());
        verify(mockFavoritesDataSource.getFavoriteIds());
      },
    );
  });

  group('toggleFavorite', () {
    test('should call toggleFavorite on the data source and return its result', () async {
      // arrange
      when(mockFavoritesDataSource.toggleFavorite('1')).thenAnswer((_) async => true);

      // act
      final result = await repository.toggleFavorite('1');

      // assert
      expect(result, isTrue);
      verify(mockFavoritesDataSource.toggleFavorite('1'));
    });
  });

  group('isFavorite', () {
    test('should call isFavorite on the data source and return its result', () async {
      // arrange
      when(mockFavoritesDataSource.isFavorite('1')).thenAnswer((_) async => true);

      // act
      final result = await repository.isFavorite('1');

      // assert
      expect(result, isTrue);
      verify(mockFavoritesDataSource.isFavorite('1'));
    });
  });
}