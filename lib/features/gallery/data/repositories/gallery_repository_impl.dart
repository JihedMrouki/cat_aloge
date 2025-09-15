import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final DevicePhotoDataSource photoDataSource;

  GalleryRepositoryImpl({
    required this.photoDataSource,
  });

  @override
  Future<List<CatPhoto>> getCatPhotos() async {
    return await photoDataSource.getCatPhotos();
  }

  @override
  Future<void> refreshPhotos() async {
    await photoDataSource.refreshPhotos();
  }
}