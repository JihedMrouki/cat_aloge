// lib/features/gallery/domain/entities/cat_photo.dart (Updated)
import 'detection_result.dart';

class CatPhoto {
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

  // Factory constructors for different creation scenarios
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

  factory CatPhoto.fromMockData({
    required String id,
    required String path,
    String? fileName,
    DateTime? dateAdded,
  }) {
    return CatPhoto(
      id: id,
      path: path,
      fileName: fileName ?? 'Mock Cat Photo',
      dateAdded: dateAdded ?? DateTime.now(),
      sizeBytes: 0,
      width: 800,
      height: 600,
      detectionResult: DetectionResult.detected(
        confidence: 0.95,
        boundingBoxes: const [
          BoundingBox(x: 0.1, y: 0.1, width: 0.8, height: 0.8, label: 'cat'),
        ],
        processingTimeMs: 150,
      ),
    );
  }

  // Computed properties
  double get aspectRatio => height != 0 ? width / height : 1.0;

  String get sizeDescription {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get dimensionsDescription => '${width} × ${height}';

  bool get hasHighConfidenceDetection =>
      detectionResult?.hasCat == true &&
      (detectionResult?.confidence ?? 0) >= 0.8;

  String get confidenceBadgeText {
    final result = detectionResult;
    if (result == null || !result.hasCat) return '';

    return switch (result.confidenceLevel) {
      ConfidenceLevel.high => '😻',
      ConfidenceLevel.medium => '😸',
      ConfidenceLevel.low => '🙂',
      ConfidenceLevel.veryLow => '🤔',
    };
  }

  // Copy methods for state updates
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

  CatPhoto toggleFavorite() => copyWith(isFavorite: !isFavorite);

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
    return 'CatPhoto('
        'id: $id, '
        'fileName: $fileName, '
        'size: $sizeDescription, '
        'dimensions: $dimensionsDescription, '
        'hasCat: ${detectionResult?.hasCat ?? false}, '
        'confidence: ${detectionResult != null ? (detectionResult!.confidence * 100).toStringAsFixed(1) : 'N/A'}%, '
        'isFavorite: $isFavorite'
        ')';
  }
}
