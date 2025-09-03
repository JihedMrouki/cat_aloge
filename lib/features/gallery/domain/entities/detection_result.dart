class DetectionResult {
  final bool hasCat;
  final double confidence;
  final List<BoundingBox> boundingBoxes;
  final int processingTimeMs;
  final DateTime detectedAt;

  DetectionResult({
    required this.hasCat,
    required this.confidence,
    required this.boundingBoxes,
    required this.processingTimeMs,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  // --- MANUAL JSON CONVERSION ---

  /// Creates a DetectionResult instance from a JSON map.
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      hasCat: json['hasCat'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      boundingBoxes: (json['boundingBoxes'] as List<dynamic>)
          .map((item) => BoundingBox.fromJson(item as Map<String, dynamic>))
          .toList(),
      processingTimeMs: json['processingTimeMs'] as int,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  /// Converts this DetectionResult instance to a JSON map.
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

  String get performanceDescription {
    if (processingTimeMs < 100) return 'Very fast';
    if (processingTimeMs < 500) return 'Fast';
    if (processingTimeMs < 1000) return 'Moderate';
    return 'Slow';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionResult &&
          runtimeType == other.runtimeType &&
          hasCat == other.hasCat &&
          confidence == other.confidence &&
          boundingBoxes == other.boundingBoxes &&
          processingTimeMs == other.processingTimeMs &&
          detectedAt == other.detectedAt;

  @override
  int get hashCode =>
      hasCat.hashCode ^
      confidence.hashCode ^
      boundingBoxes.hashCode ^
      processingTimeMs.hashCode ^
      detectedAt.hashCode;
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

  // --- MANUAL JSON CONVERSION ---

  /// Creates a BoundingBox instance from a JSON map.
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      label: json['label'] as String?,
      labelConfidence: (json['labelConfidence'] as num?)?.toDouble(),
    );
  }

  /// Converts this BoundingBox instance to a JSON map.
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

  // --- EXISTING HELPERS ---

  ({double x, double y}) get center => (x: x + width / 2, y: y + height / 2);
  double get area => width * height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoundingBox &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          label == other.label &&
          labelConfidence == other.labelConfidence;

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      width.hashCode ^
      height.hashCode ^
      label.hashCode ^
      labelConfidence.hashCode;
}

enum ConfidenceLevel { veryLow, low, medium, high }
