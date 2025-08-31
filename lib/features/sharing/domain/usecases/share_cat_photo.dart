import 'package:cat_aloge/features/sharing/data/repository/share_repository_impl.dart';

class ShareCatPhoto {
  final ShareRepositoryImpl _repository;

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
