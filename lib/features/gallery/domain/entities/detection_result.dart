class DetectionResult {
  final bool hasCat;
  final double confidence;
  final List<BoundingBox> boundingBoxes;
  final CatBreed? breed;
  final List<String> features;

  const DetectionResult({
    required this.hasCat,
    required this.confidence,
    required this.boundingBoxes,
    this.breed,
    this.features = const [],
  });

  @override
  List<Object?> get props => [
    hasCat,
    confidence,
    boundingBoxes,
    breed,
    features,
  ];
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  @override
  List<Object> get props => [x, y, width, height, confidence];
}

class CatBreed {
  final String name;
  final double confidence;
  final String description;

  const CatBreed({
    required this.name,
    required this.confidence,
    required this.description,
  });

  @override
  List<Object> get props => [name, confidence, description];
}

class PhotoMetadata {
  final int width;
  final int height;
  final int fileSize;
  final DateTime? dateTaken;
  final String? location;

  const PhotoMetadata({
    required this.width,
    required this.height,
    required this.fileSize,
    this.dateTaken,
    this.location,
  });

  @override
  List<Object?> get props => [width, height, fileSize, dateTaken, location];
}
