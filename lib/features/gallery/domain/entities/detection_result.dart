class DetectionResult {
  final bool hasCat;
  final double confidence;
  final List<BoundingBox> boundingBoxes;
  final int processingTimeMs;
  final String? error;

  const DetectionResult({
    required this.hasCat,
    required this.confidence,
    required this.boundingBoxes,
    required this.processingTimeMs,
    this.error,
  });

  factory DetectionResult.error(String error, int processingTimeMs) {
    return DetectionResult(
      hasCat: false,
      confidence: 0.0,
      boundingBoxes: const [],
      processingTimeMs: processingTimeMs,
      error: error,
    );
  }

  factory DetectionResult.noCat(int processingTimeMs) {
    return DetectionResult(
      hasCat: false,
      confidence: 0.0,
      boundingBoxes: const [],
      processingTimeMs: processingTimeMs,
    );
  }

  bool get hasError => error != null;

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  DetectionResult copyWith({
    bool? hasCat,
    double? confidence,
    List<BoundingBox>? boundingBoxes,
    int? processingTimeMs,
    String? error,
  }) {
    return DetectionResult(
      hasCat: hasCat ?? this.hasCat,
      confidence: confidence ?? this.confidence,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    hasCat,
    confidence,
    boundingBoxes,
    processingTimeMs,
    error,
  ];

  @override
  String toString() {
    return 'DetectionResult{'
        'hasCat: $hasCat, '
        'confidence: $confidencePercentage, '
        'boundingBoxes: ${boundingBoxes.length}, '
        'processingTime: ${processingTimeMs}ms'
        '${hasError ? ', error: $error' : ''}'
        '}';
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String? label;
  final double? labelConfidence;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.label,
    this.labelConfidence,
  });

  // Convert normalized coordinates to pixel coordinates
  BoundingBox toPixelCoordinates(int imageWidth, int imageHeight) {
    return BoundingBox(
      x: x * imageWidth,
      y: y * imageHeight,
      width: width * imageWidth,
      height: height * imageHeight,
      label: label,
      labelConfidence: labelConfidence,
    );
  }

  // Convert pixel coordinates to normalized coordinates
  BoundingBox toNormalizedCoordinates(int imageWidth, int imageHeight) {
    return BoundingBox(
      x: x / imageWidth,
      y: y / imageHeight,
      width: width / imageWidth,
      height: height / imageHeight,
      label: label,
      labelConfidence: labelConfidence,
    );
  }

  double get centerX => x + (width / 2);
  double get centerY => y + (height / 2);
  double get area => width * height;

  String? get labelWithConfidence {
    if (label == null) return null;
    if (labelConfidence == null) return label;
    return '$label (${(labelConfidence! * 100).toStringAsFixed(1)}%)';
  }

  BoundingBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    String? label,
    double? labelConfidence,
  }) {
    return BoundingBox(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
      labelConfidence: labelConfidence ?? this.labelConfidence,
    );
  }

  @override
  List<Object?> get props => [x, y, width, height, label, labelConfidence];

  @override
  String toString() {
    return 'BoundingBox{'
        'x: ${x.toStringAsFixed(3)}, '
        'y: ${y.toStringAsFixed(3)}, '
        'width: ${width.toStringAsFixed(3)}, '
        'height: ${height.toStringAsFixed(3)}'
        '${labelWithConfidence != null ? ', label: $labelWithConfidence' : ''}'
        '}';
  }
}
