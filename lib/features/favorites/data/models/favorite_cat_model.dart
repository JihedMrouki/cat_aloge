import 'package:cat_aloge/features/favorites/domain/entities/favorite_cat.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'favorite_cat_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class FavoriteCatModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String catPhotoId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final DateTime dateAdded;

  @HiveField(5)
  final String? notes;

  const FavoriteCatModel({
    required this.id,
    required this.catPhotoId,
    required this.name,
    required this.imagePath,
    required this.dateAdded,
    this.notes,
  });

  factory FavoriteCatModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteCatModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteCatModelToJson(this);

  factory FavoriteCatModel.fromEntity(FavoriteCat entity) {
    return FavoriteCatModel(
      id: entity.id,
      catPhotoId: entity.catPhotoId,
      name: entity.name,
      imagePath: entity.imagePath,
      dateAdded: entity.dateAdded,
      notes: entity.notes,
    );
  }

  FavoriteCat toEntity() {
    return FavoriteCat(
      id: id,
      catPhotoId: catPhotoId,
      name: name,
      imagePath: imagePath,
      dateAdded: dateAdded,
      notes: notes,
    );
  }
}