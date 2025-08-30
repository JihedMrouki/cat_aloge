import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

class DetectionResultModel extends DetectionResult {
  const DetectionResultModel({
    required super.confidence,
    required super.hasCat,
    required super.boundingBoxes,
    super.breed,
  });

  factory DetectionResultModel.fromJson(Map<String, dynamic> json) {
    return DetectionResultModel(
      confidence: (json['confidence'] as num).toDouble(),
      hasCat: json['hasCat'] as bool,
      boundingBoxes: (json['boundingBoxes'] as List<dynamic>)
          .map((box) => BoundingBoxModel.fromJson(box))
          .toList(),
      breed: json['breed'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'hasCat': hasCat,
      'boundingBoxes': boundingBoxes
          .map((box) => BoundingBoxModel.fromEntity(box).toJson())
          .toList(),
      'breed': breed,
    };
  }
}

class BoundingBoxModel extends BoundingBox {
  const BoundingBoxModel({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
  });

  factory BoundingBoxModel.fromJson(Map<String, dynamic> json) {
    return BoundingBoxModel(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }

  factory BoundingBoxModel.fromEntity(BoundingBox entity) {
    return BoundingBoxModel(
      x: entity.x,
      y: entity.y,
      width: entity.width,
      height: entity.height,
    );
  }
}
