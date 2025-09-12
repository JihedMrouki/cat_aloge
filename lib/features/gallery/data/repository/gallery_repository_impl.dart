// lib/features/gallery/data/repository/gallery_repository_impl.dart

import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final DevicePhotoDataSource _devicePhotoDataSource;

  GalleryRepositoryImpl(this._devicePhotoDataSource);

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    // The datasource is already returning the entity, so we just pass it through.
    // In a more complex app, this is where you would map a Model to an Entity.
    return await _devicePhotoDataSource.getCatPhotos();
  }

  @override
  Future<List<CatPhoto>> refreshPhotos() async {
    await _devicePhotoDataSource.refreshPhotos();
    return await getCatPhotos(); // Re-fetch after refreshing
  }

  @override
  Future<void> clearCache() async {
    await _devicePhotoDataSource.clearCache();
  }
}
