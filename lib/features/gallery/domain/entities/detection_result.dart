class DetectionResult {
  final bool hasCat;
  final double confidence;
  final List<BoundingBox> boundingBoxes;
  final int processingTimeMs;
  final DateTime detectedAt;

  const DetectionResult({
    required this.hasCat,
    required this.confidence,
    required this.boundingBoxes,
    required this.processingTimeMs,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DetectionResult._defaultDateTime();

  DetectionResult._defaultDateTime() : detectedAt = null;

  // Factory for creating detection results
  factory DetectionResult.detected({
    required double confidence,
    required List<BoundingBox> boundingBoxes,
    required int processingTimeMs,
  }) {
    return DetectionResult(
      hasCat: true,
      confidence: confidence,
      boundingBoxes: boundingBoxes,
      processingTimeMs: processingTimeMs,
      detectedAt: DateTime.now(),
    );
  }

  factory DetectionResult.notDetected({int processingTimeMs = 0}) {
    return DetectionResult(
      hasCat: false,
      confidence: 0.0,
      boundingBoxes: const [],
      processingTimeMs: processingTimeMs,
      detectedAt: DateTime.now(),
    );
  }

  // Confidence level helpers
  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.9) return ConfidenceLevel.high;
    if (confidence >= 0.7) return ConfidenceLevel.medium;
    if (confidence >= 0.5) return ConfidenceLevel.low;
    return ConfidenceLevel.veryLow;
  }

  String get confidenceDescription {
    switch (confidenceLevel) {
      case ConfidenceLevel.high:
        return 'Very confident';
      case ConfidenceLevel.medium:
        return 'Confident';
      case ConfidenceLevel.low:
        return 'Somewhat confident';
      case ConfidenceLevel.veryLow:
        return 'Low confidence';
    }
  }

  // Performance metrics
  String get performanceDescription {
    if (processingTimeMs < 100) return 'Very fast';
    if (processingTimeMs < 500) return 'Fast';
    if (processingTimeMs < 1000) return 'Moderate';
    return 'Slow';
  }

  @override
  List<Object?> get props => [
    hasCat,
    confidence,
    boundingBoxes,
    processingTimeMs,
    detectedAt,
  ];

  @override
  String toString() {
    return 'DetectionResult('
        'hasCat: $hasCat, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'boxes: ${boundingBoxes.length}, '
        'time: ${processingTimeMs}ms'
        ')';
  }
}

class BoundingBox {
  final double x; // Normalized 0.0 - 1.0
  final double y; // Normalized 0.0 - 1.0
  final double width; // Normalized 0.0 - 1.0
  final double height; // Normalized 0.0 - 1.0
  final String? label; // Optional label (e.g., "cat", "kitten")
  final double? labelConfidence; // Confidence for the specific label

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.label,
    this.labelConfidence,
  });

  // Convert normalized coordinates to actual pixel coordinates
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

  // Get center point of bounding box
  ({double x, double y}) get center => (x: x + width / 2, y: y + height / 2);

  // Get area of bounding box
  double get area => width * height;

  // Check if this bounding box overlaps with another
  bool overlapsWith(BoundingBox other, {double threshold = 0.5}) {
    final overlapArea = _calculateOverlapArea(other);
    final unionArea = area + other.area - overlapArea;
    return (overlapArea / unionArea) >= threshold;
  }

  double _calculateOverlapArea(BoundingBox other) {
    final left = x > other.x ? x : other.x;
    final right = (x + width) < (other.x + other.width)
        ? (x + width)
        : (other.x + other.width);
    final top = y > other.y ? y : other.y;
    final bottom = (y + height) < (other.y + other.height)
        ? (y + height)
        : (other.y + other.height);

    if (left >= right || top >= bottom) return 0.0;
    return (right - left) * (bottom - top);
  }

  @override
  List<Object?> get props => [x, y, width, height, label, labelConfidence];

  @override
  String toString() {
    return 'BoundingBox('
        'x: ${x.toStringAsFixed(3)}, '
        'y: ${y.toStringAsFixed(3)}, '
        'w: ${width.toStringAsFixed(3)}, '
        'h: ${height.toStringAsFixed(3)}'
        '${label != null ? ', label: $label' : ''}'
        '${labelConfidence != null ? ', conf: ${(labelConfidence! * 100).toStringAsFixed(1)}%' : ''}'
        ')';
  }
}

enum ConfidenceLevel { veryLow, low, medium, high }
