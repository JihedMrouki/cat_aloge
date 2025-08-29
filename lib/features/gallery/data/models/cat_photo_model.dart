import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

@JsonSerializable()
class CatPhotoModel extends CatPhoto {
  const CatPhotoModel({
    required super.id,
    required super.path,
    required super.name,
    required super.dateAdded,
    required super.detectionResult,
    required super.metadata,
  });

  factory CatPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$CatPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatPhotoModelToJson(this);

  factory CatPhotoModel.fromEntity(CatPhoto entity) {
    return CatPhotoModel(
      id: entity.id,
      path: entity.path,
      name: entity.name,
      dateAdded: entity.dateAdded,
      detectionResult: entity.detectionResult,
      metadata: entity.metadata,
    );
  }

  CatPhoto toEntity() {
    return CatPhoto(
      id: id,
      path: path,
      name: name,
      dateAdded: dateAdded,
      detectionResult: detectionResult,
      metadata: metadata,
    );
  }
}
