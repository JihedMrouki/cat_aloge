// import 'package:cat_aloge/features/favorites/domain/entities/favorite_cat.dart';
// import 'package:hive/hive.dart';

// @HiveType(typeId: 0)
// @JsonSerializable()
// class FavoriteCatModel extends FavoriteCat {
//   @HiveField(0)
//   @override
//   final String id;

//   @HiveField(1)
//   @override
//   final String catPhotoId;

//   @HiveField(2)
//   @override
//   final String name;

//   @HiveField(3)
//   @override
//   final String imagePath;

//   @HiveField(4)
//   @override
//   final DateTime dateAdded;

//   @HiveField(5)
//   @override
//   final String? notes;

//   const FavoriteCatModel({
//     required this.id,
//     required this.catPhotoId,
//     required this.name,
//     required this.imagePath,
//     required this.dateAdded,
//     this.notes,
//   }) : super(
//          id: id,
//          catPhotoId: catPhotoId,
//          name: name,
//          imagePath: imagePath,
//          dateAdded: dateAdded,
//          notes: notes,
//        );

//   factory FavoriteCatModel.fromJson(Map<String, dynamic> json) =>
//       _$FavoriteCatModelFromJson(json);

//   Map<String, dynamic> toJson() => _$FavoriteCatModelToJson(this);

//   factory FavoriteCatModel.fromEntity(FavoriteCat entity) {
//     return FavoriteCatModel(
//       id: entity.id,
//       catPhotoId: entity.catPhotoId,
//       name: entity.name,
//       imagePath: entity.imagePath,
//       dateAdded: entity.dateAdded,
//       notes: entity.notes,
//     );
//   }

//   FavoriteCat toEntity() {
//     return FavoriteCat(
//       id: id,
//       catPhotoId: catPhotoId,
//       name: name,
//       imagePath: imagePath,
//       dateAdded: dateAdded,
//       notes: notes,
//     );
//   }
// }
