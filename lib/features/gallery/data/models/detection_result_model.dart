// import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

// @JsonSerializable()
// class DetectionResultModel extends DetectionResult {
//   const DetectionResultModel({
//     required super.hasCat,
//     required super.confidence,
//     required super.boundingBoxes,
//     super.breed,
//     super.features,
//   });

//   factory DetectionResultModel.fromJson(Map<String, dynamic> json) =>
//       _$DetectionResultModelFromJson(json);

//   Map<String, dynamic> toJson() => _$DetectionResultModelToJson(this);

//   factory DetectionResultModel.fromEntity(DetectionResult entity) {
//     return DetectionResultModel(
//       hasCat: entity.hasCat,
//       confidence: entity.confidence,
//       boundingBoxes: entity.boundingBoxes,
//       breed: entity.breed,
//       features: entity.features,
//     );
//   }
// }

// @JsonSerializable()
// class BoundingBoxModel extends BoundingBox {
//   const BoundingBoxModel({
//     required super.x,
//     required super.y,
//     required super.width,
//     required super.height,
//     required super.confidence,
//   });

//   factory BoundingBoxModel.fromJson(Map<String, dynamic> json) =>
//       _$BoundingBoxModelFromJson(json);

//   Map<String, dynamic> toJson() => _$BoundingBoxModelToJson(this);
// }

// @JsonSerializable()
// class CatBreedModel extends CatBreed {
//   const CatBreedModel({
//     required super.name,
//     required super.confidence,
//     required super.description,
//   });

//   factory CatBreedModel.fromJson(Map<String, dynamic> json) =>
//       _$CatBreedModelFromJson(json);

//   Map<String, dynamic> toJson() => _$CatBreedModelToJson(this);
// }
