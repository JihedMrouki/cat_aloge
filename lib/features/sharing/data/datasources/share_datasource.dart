import 'package:share_plus/share_plus.dart';

abstract class ShareDataSource {
  Future<void> shareText(String text, {String? subject});
  Future<void> shareFile(String filePath, {String? text, String? subject});
  Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  });
}

class SharePlusDataSource implements ShareDataSource {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject); // Reverted
  }

  @override
  Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    await Share.shareXFiles([XFile(filePath)], text: text, subject: subject); // Reverted
  }

  @override
  Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(xFiles, text: text, subject: subject); // Reverted
  }
}
