import 'package:cat_aloge/features/gallery/data/models/detection_result_model.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class CatPhotoModel extends CatPhoto {
  const CatPhotoModel({
    required super.id,
    required super.path,
    required super.fileName,
    required super.isFavorite,
    super.detectionResult,
    required super.creationDate,
    required super.fileSize,
  });

  factory CatPhotoModel.fromJson(Map<String, dynamic> json) {
    final detectionResultJson =
        json['detectionResult'] as Map<String, dynamic>?;

    return CatPhotoModel(
      id: json['id'] as String,
      path: json['path'] as String,
      fileName: json['fileName'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      detectionResult: detectionResultJson != null
          ? DetectionResultModel.fromJson(detectionResultJson)
          : null,
      creationDate: DateTime.parse(json['creationDate'] as String),
      fileSize: json['fileSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'fileName': fileName,
      'isFavorite': isFavorite,
      'detectionResult': detectionResult != null ? DetectionResultModel(confidence: detectionResult!.confidence, label: detectionResult!.label).toJson() : null,
      'creationDate': creationDate.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  factory CatPhotoModel.fromEntity(CatPhoto entity) {
    return CatPhotoModel(
      id: entity.id,
      path: entity.path,
      fileName: entity.fileName,
      isFavorite: entity.isFavorite,
      detectionResult: entity.detectionResult,
      creationDate: entity.creationDate,
      fileSize: entity.fileSize,
    );
  }

  @override
  CatPhoto toEntity() {
    return CatPhoto(
      id: id,
      path: path,
      fileName: fileName,
      isFavorite: isFavorite,
      detectionResult: detectionResult,
      creationDate: creationDate,
      fileSize: fileSize,
    );
  }

  @override
  CatPhoto copyWith({
    String? id,
    String? path,
    String? fileName,
    bool? isFavorite,
    DetectionResult? detectionResult,
    DateTime? creationDate,
    int? fileSize,
  }) {
    return CatPhotoModel(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      isFavorite: isFavorite ?? this.isFavorite,
      detectionResult: detectionResult ?? this.detectionResult,
      creationDate: creationDate ?? this.creationDate,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
