import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:equatable/equatable.dart';

class CatPhoto extends Equatable {
  final String id;
  final String path;
  final String fileName;
  final DateTime dateAdded;
  final int sizeBytes;
  final int width;
  final int height;
  final DetectionResult? detectionResult;
  final DateTime? lastModified;
  final String? mimeType;
  final bool isFavorite;

  const CatPhoto({
    required this.id,
    required this.path,
    required this.fileName,
    required this.dateAdded,
    required this.sizeBytes,
    required this.width,
    required this.height,
    this.detectionResult,
    this.lastModified,
    this.mimeType,
    this.isFavorite = false,
  });

  factory CatPhoto.fromDevicePhoto({
    required String id,
    required String path,
    required String fileName,
    required DateTime dateAdded,
    required int sizeBytes,
    required int width,
    required int height,
    DetectionResult? detectionResult,
    DateTime? lastModified,
    String? mimeType,
    bool isFavorite = false,
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
      isFavorite: isFavorite,
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
    return '${width}x$height';
  }

  double get confidencePercentage {
    return (detectionResult?.confidence ?? 0.0) * 100;
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
    bool? isFavorite,
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
      isFavorite: isFavorite ?? this.isFavorite,
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
    isFavorite,
  ];

  @override
  String toString() {
    return 'CatPhoto{'
        'id: $id, '
        'fileName: $fileName, '
        'confidence: ${confidencePercentage.toStringAsFixed(1)}%, '
        'size: $fileSizeFormatted, '
        'resolution: $resolutionFormatted, '
        'isFavorite: $isFavorite'
        '}';
  }
}
