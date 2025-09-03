import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class CatPhotoModel extends CatPhoto {
  const CatPhotoModel({
    required super.id,
    required super.path,
    required super.fileName,
    required super.dateAdded,
    required super.sizeBytes,
    required super.width,
    required super.height,
    super.detectionResult,
    super.lastModified,
    super.mimeType,
    super.isFavorite,
  });

  // --- MANUAL JSON CONVERSION ---

  /// Creates a CatPhotoModel instance from a JSON map.
  factory CatPhotoModel.fromJson(Map<String, dynamic> json) {
    final detectionResultJson =
        json['detectionResult'] as Map<String, dynamic>?;

    return CatPhotoModel(
      id: json['id'] as String,
      path: json['path'] as String,
      fileName: json['fileName'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      sizeBytes: json['sizeBytes'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      detectionResult: detectionResultJson != null
          ? DetectionResult.fromJson(detectionResultJson)
          : null,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
      mimeType: json['mimeType'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Converts this CatPhotoModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'fileName': fileName,
      'dateAdded': dateAdded.toIso8601String(),
      'sizeBytes': sizeBytes,
      'width': width,
      'height': height,
      'detectionResult': detectionResult?.toJson(),
      'lastModified': lastModified?.toIso8601String(),
      'mimeType': mimeType,
      'isFavorite': isFavorite,
    };
  }

  // --- EXISTING FACTORIES & HELPERS ---

  factory CatPhotoModel.fromEntity(CatPhoto entity) {
    return CatPhotoModel(
      id: entity.id,
      path: entity.path,
      fileName: entity.fileName,
      dateAdded: entity.dateAdded,
      sizeBytes: entity.sizeBytes,
      width: entity.width,
      height: entity.height,
      detectionResult: entity.detectionResult,
      lastModified: entity.lastModified,
      mimeType: entity.mimeType,
      isFavorite: entity.isFavorite,
    );
  }

  CatPhoto toEntity() {
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

  @override
  CatPhotoModel copyWith({
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
    return CatPhotoModel(
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
}
