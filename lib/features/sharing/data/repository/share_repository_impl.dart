import 'package:cat_aloge/features/sharing/data/datasources/share_datasource.dart';
import 'package:cat_aloge/features/sharing/domain/repositories/share_repository.dart';

class ShareRepositoryImpl implements ShareRepository {
  final ShareDataSource _shareDataSource;

  const ShareRepositoryImpl(this._shareDataSource);

  @override
  Future<void> sharePhoto({
    required String photoPath,
    String? text,
    String? subject,
  }) async {
    await _shareDataSource.shareFile(photoPath, text: text, subject: subject);
  }

  @override
  Future<void> sharePhotos({
    required List<String> photoPaths,
    String? text,
    String? subject,
  }) async {
    await _shareDataSource.shareFiles(photoPaths, text: text, subject: subject);
  }

  @override
  Future<void> sharePhotoWithMetadata({
    required String photoPath,
    required double confidence,
    String? additionalText,
  }) async {
    final metadata = 'Cat Detection: ${(confidence * 100).toStringAsFixed(1)}%';
    final fullText = additionalText != null
        ? '$additionalText\n\n$metadata'
        : 'Check out this cat photo!\n\n$metadata';

    await _shareDataSource.shareText(fullText, subject: 'Cat Photo');
  }
}
