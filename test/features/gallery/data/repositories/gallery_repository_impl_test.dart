import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'gallery_repository_impl_test.mocks.dart';

@GenerateMocks([DevicePhotoDataSource])
void main() {
  late GalleryRepositoryImpl repository;
  late MockDevicePhotoDataSource mockPhotoDataSource;

  setUp(() {
    mockPhotoDataSource = MockDevicePhotoDataSource();
    repository = GalleryRepositoryImpl(photoDataSource: mockPhotoDataSource);
  });

  group('getCatPhotos', () {
    final tCatPhotoList = [
      CatPhoto(id: '1', path: 'path1', fileName: 'file1', isFavorite: false, creationDate: DateTime(2023, 1, 1), fileSize: 100),
      CatPhoto(id: '2', path: 'path2', fileName: 'file2', isFavorite: false, creationDate: DateTime(2023, 1, 2), fileSize: 200),
    ];

    test(
      'should return a list of CatPhoto when the call to the data source is successful',
      () async {
        // arrange
        when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => tCatPhotoList);
        // act
        final result = await repository.getCatPhotos();
        // assert
        verify(mockPhotoDataSource.getCatPhotos());
        expect(result, equals(tCatPhotoList));
      },
    );

    test(
      'should return an empty list when the data source returns an empty list',
      () async {
        // arrange
        when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => []);
        // act
        final result = await repository.getCatPhotos();
        // assert
        verify(mockPhotoDataSource.getCatPhotos());
        expect(result, isEmpty);
      },
    );

    test(
      'should throw an exception when the call to the data source is unsuccessful',
      () async {
        // arrange
        when(mockPhotoDataSource.getCatPhotos()).thenThrow(Exception('Test Exception'));
        // act
        final call = repository.getCatPhotos;
        // assert
        expect(() => call(), throwsA(isA<Exception>()));
      },
    );
  });

  group('refreshPhotos', () {
    test('should call refreshPhotos on the data source', () async {
      // arrange
      when(mockPhotoDataSource.refreshPhotos()).thenAnswer((_) async => Future.value());
      // act
      await repository.refreshPhotos();
      // assert
      verify(mockPhotoDataSource.refreshPhotos());
      verifyNoMoreInteractions(mockPhotoDataSource);
    });
  });
}