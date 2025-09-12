import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class DetectionResultModel extends DetectionResult {
  // Overriding the list to be of the Model type for easier serialization.
  @override
  @override
  final List<BoundingBoxModel> boundingBoxes;

  DetectionResultModel({
    required super.hasCat,
    required super.confidence,
    required this.boundingBoxes, // Use the local field
    required super.processingTimeMs,
    super.detectedAt,
  }) : super(
         boundingBoxes: boundingBoxes,
       ); // Pass the model list to the super constructor.

  // --- MANUAL JSON CONVERSION ---

  /// Creates a DetectionResultModel instance from a JSON map.
  factory DetectionResultModel.fromJson(Map<String, dynamic> json) {
    return DetectionResultModel(
      hasCat: json['hasCat'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBoxes: (json['boundingBoxes'] as List<dynamic>)
          .map(
            (item) => BoundingBoxModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      processingTimeMs: json['processingTimeMs'] as int,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  /// Converts this DetectionResultModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'hasCat': hasCat,
      'confidence': confidence,
      'boundingBoxes': boundingBoxes.map((box) => box.toJson()).toList(),
      'processingTimeMs': processingTimeMs,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  // --- EXISTING FACTORIES & HELPERS ---

  /// Creates a Model from a domain Entity.
  factory DetectionResultModel.fromEntity(DetectionResult entity) {
    return DetectionResultModel(
      hasCat: entity.hasCat,
      confidence: entity.confidence,
      boundingBoxes: entity.boundingBoxes
          .map((box) => BoundingBoxModel.fromEntity(box))
          .toList(),
      processingTimeMs: entity.processingTimeMs,
      detectedAt: entity.detectedAt,
    );
  }

  /// Converts this Model to a domain Entity.
  DetectionResult toEntity() {
    return DetectionResult(
      hasCat: hasCat,
      confidence: confidence,
      boundingBoxes: boundingBoxes.map((box) => box.toEntity()).toList(),
      processingTimeMs: processingTimeMs,
      detectedAt: detectedAt,
    );
  }
}

class BoundingBoxModel extends BoundingBox {
  const BoundingBoxModel({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.label,
    super.labelConfidence,
  });

  // --- MANUAL JSON CONVERSION ---

  /// Creates a BoundingBoxModel instance from a JSON map.
  factory BoundingBoxModel.fromJson(Map<String, dynamic> json) {
    return BoundingBoxModel(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      label: json['label'] as String?,
      labelConfidence: (json['labelConfidence'] as num?)?.toDouble(),
    );
  }

  /// Converts this BoundingBoxModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'label': label,
      'labelConfidence': labelConfidence,
    };
  }

  // --- EXISTING FACTORIES & HELPERS ---

  /// Creates a Model from a domain Entity.
  factory BoundingBoxModel.fromEntity(BoundingBox entity) {
    return BoundingBoxModel(
      x: entity.x,
      y: entity.y,
      width: entity.width,
      height: entity.height,
      label: entity.label,
      labelConfidence: entity.labelConfidence,
    );
  }

  /// Converts this Model to a domain Entity.
  BoundingBox toEntity() {
    return BoundingBox(
      x: x,
      y: y,
      width: width,
      height: height,
      label: label,
      labelConfidence: labelConfidence,
    );
  }
}
