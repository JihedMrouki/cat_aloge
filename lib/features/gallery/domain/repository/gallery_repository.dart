// lib/features/gallery/domain/repository/gallery_repository.dart

import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

abstract class GalleryRepository {
  /// Fetches all photos identified as containing a cat from the device.
  Future<List<CatPhoto>> getCatPhotos();

  /// Forces a re-scan of the device for cat photos, clearing any existing cache.
  Future<List<CatPhoto>> refreshPhotos();

  /// Clears all cached photo data.
  Future<void> clearCache();
}
