import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class CatPhoto {
  final String id;
  final String path;
  final String fileName;
  final DateTime dateAdded;
  final int sizeBytes;
  final int width;
  final int height;
  final DetectionResult detectionResult;
  final DateTime? lastModified;
  final String? mimeType;

  const CatPhoto({
    required this.id,
    required this.path,
    required this.fileName,
    required this.dateAdded,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.detectionResult,
    this.lastModified,
    this.mimeType,
  });

  factory CatPhoto.fromDevicePhoto({
    required String id,
    required String path,
    required String fileName,
    required DateTime dateAdded,
    required int sizeBytes,
    required int width,
    required int height,
    required DetectionResult detectionResult,
    DateTime? lastModified,
    String? mimeType,
  }) {
    return CatPhoto(
      id: id,
      path: path,
      fileName: fileName,
      dateAdded: dateAdded,
      sizeBytes: sizeBytes,
      width: width,
      height: height,
      detectionResult: detectionResult,
      lastModified: lastModified,
      mimeType: mimeType,
    );
  }

  String get fileSizeFormatted {
    if (sizeBytes < 1024) {
      return '${sizeBytes}B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get aspectRatioFormatted {
    if (width == 0 || height == 0) return 'Unknown';
    final ratio = width / height;
    return '${ratio.toStringAsFixed(2)}:1';
  }

  String get resolutionFormatted {
    return '${width}x${height}';
  }

  double get confidencePercentage {
    return detectionResult.confidence * 100;
  }

  CatPhoto copyWith({
    String? id,
    String? path,
    String? fileName,
    DateTime? dateAdded,
    int? sizeBytes,
    int? width,
    int? height,
    DetectionResult? detectionResult,
    DateTime? lastModified,
    String? mimeType,
  }) {
    return CatPhoto(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      dateAdded: dateAdded ?? this.dateAdded,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      detectionResult: detectionResult ?? this.detectionResult,
      lastModified: lastModified ?? this.lastModified,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    path,
    fileName,
    dateAdded,
    sizeBytes,
    width,
    height,
    detectionResult,
    lastModified,
    mimeType,
  ];

  @override
  String toString() {
    return 'CatPhoto{'
        'id: $id, '
        'fileName: $fileName, '
        'confidence: ${confidencePercentage.toStringAsFixed(1)}%, '
        'size: $fileSizeFormatted, '
        'resolution: $resolutionFormatted'
        '}';
  }
}
