import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetectCatsInPhoto {
  final GalleryRepository _repository;

  DetectCatsInPhoto(this._repository);

  Future<DetectionResult> call(String imagePath) async {
    try {
      return await _repository.detectCatsInPhoto(imagePath);
    } catch (e) {
      throw Exception('Failed to detect cats in photo: $e');
    }
  }
}

final detectCatsInPhotoProvider = Provider<DetectCatsInPhoto>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return DetectCatsInPhoto(repository);
});
