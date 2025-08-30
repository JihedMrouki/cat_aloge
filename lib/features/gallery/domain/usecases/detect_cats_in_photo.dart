import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';

class DetectCatsInPhoto {
  final GalleryRepository _repository;

  const DetectCatsInPhoto(this._repository);

  Future<DetectionResult> call(String photoPath) async {
    return await _repository.detectCatsInPhoto(photoPath);
  }
}
