import 'package:cat_aloge/features/sharing/data/repository/share_repository.dart';

class ShareCatPhoto {
  final ShareRepository _repository;

  const ShareCatPhoto(this._repository);

  Future<void> call({
    required String photoPath,
    required double confidence,
    String? additionalText,
  }) async {
    return await _repository.sharePhotoWithMetadata(
      photoPath: photoPath,
      confidence: confidence,
      additionalText: additionalText,
    );
  }
}
