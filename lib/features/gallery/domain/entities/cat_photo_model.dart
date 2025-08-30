import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

class CatPhotoModel extends CatPhoto {
  const CatPhotoModel({
    required super.id,
    required super.url,
    required super.path,
    required super.confidence,
    required super.isFavorite,
    required super.createdAt,
    super.modifiedAt,
  });

  factory CatPhotoModel.fromJson(Map<String, dynamic> json) {
    return CatPhotoModel(
      id: json['id'] as String,
      url: json['url'] as String,
      path: json['path'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'path': path,
      'confidence': confidence,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  factory CatPhotoModel.fromEntity(CatPhoto entity) {
    return CatPhotoModel(
      id: entity.id,
      url: entity.url,
      path: entity.path,
      confidence: entity.confidence,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      modifiedAt: entity.modifiedAt,
    );
  }

  CatPhoto toEntity() {
    return CatPhoto(
      id: id,
      url: url,
      path: path,
      confidence: confidence,
      isFavorite: isFavorite,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  CatPhotoModel copyWith({
    String? id,
    String? url,
    String? path,
    double? confidence,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return CatPhotoModel(
      id: id ?? this.id,
      url: url ?? this.url,
      path: path ?? this.path,
      confidence: confidence ?? this.confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
