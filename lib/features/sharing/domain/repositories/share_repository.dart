abstract class ShareRepository {
  /// Share a single photo
  Future<void> sharePhoto({
    required String photoPath,
    String? text,
    String? subject,
  });

  /// Share multiple photos
  Future<void> sharePhotos({
    required List<String> photoPaths,
    String? text,
    String? subject,
  });
}
