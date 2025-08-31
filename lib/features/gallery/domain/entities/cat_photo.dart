// lib/features/gallery/domain/entities/cat_photo.dart
class CatPhoto {
  final String id;
  final String url;
  final String path;
  final double confidence;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? modifiedAt;

  const CatPhoto({
    required this.id,
    required this.url,
    required this.path,
    required this.confidence,
    required this.isFavorite,
    required this.createdAt,
    this.modifiedAt,
  });

  CatPhoto copyWith({
    String? id,
    String? url,
    String? path,
    double? confidence,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return CatPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      path: path ?? this.path,
      confidence: confidence ?? this.confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatPhoto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CatPhoto(id: $id, confidence: $confidence, isFavorite: $isFavorite)';
  }
}

// lib/features/gallery/domain/entities/detection_result.dart
class DetectionResult {
  final double confidence;
  final bool hasCat;
  final List<BoundingBox> boundingBoxes;
  final String? breed;

  const DetectionResult({
    required this.confidence,
    required this.hasCat,
    required this.boundingBoxes,
    this.breed,
  });

  @override
  String toString() {
    return 'DetectionResult(confidence: $confidence, hasCat: $hasCat, boxes: ${boundingBoxes.length})';
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, w: $width, h: $height)';
  }
}
