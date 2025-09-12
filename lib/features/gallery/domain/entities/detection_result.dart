// lib/features/gallery/domain/entities/detection_result.dart
import 'package:equatable/equatable.dart';

enum ConfidenceLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh;

  static ConfidenceLevel fromConfidence(double confidence) {
    if (confidence >= 0.9) return ConfidenceLevel.veryHigh;
    if (confidence >= 0.75) return ConfidenceLevel.high;
    if (confidence >= 0.5) return ConfidenceLevel.medium;
    if (confidence >= 0.25) return ConfidenceLevel.low;
    return ConfidenceLevel.veryLow;
  }

  String get displayName {
    switch (this) {
      case ConfidenceLevel.veryLow:
        return 'Very Low';
      case ConfidenceLevel.low:
        return 'Low';
      case ConfidenceLevel.medium:
        return 'Medium';
      case ConfidenceLevel.high:
        return 'High';
      case ConfidenceLevel.veryHigh:
        return 'Very High';
    }
  }
}

class DetectionResult extends Equatable {
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

  ConfidenceLevel get confidenceLevel =>
      ConfidenceLevel.fromConfidence(confidence);

  double get confidencePercentage => confidence * 100;

  String get confidenceText => '${confidencePercentage.toStringAsFixed(1)}%';

  String get processingTimeText => '${processingTimeMs}ms';

  // JSON serialization
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

  Map<String, dynamic> toJson() {
    return {
      'hasCat': hasCat,
      'confidence': confidence,
      'boundingBoxes': boundingBoxes.map((box) => box.toJson()).toList(),
      'processingTimeMs': processingTimeMs,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  DetectionResult copyWith({
    bool? hasCat,
    double? confidence,
    List<BoundingBox>? boundingBoxes,
    int? processingTimeMs,
    DateTime? detectedAt,
  }) {
    return DetectionResult(
      hasCat: hasCat ?? this.hasCat,
      confidence: confidence ?? this.confidence,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      detectedAt: detectedAt ?? this.detectedAt,
    );
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
    return 'DetectionResult{'
        'hasCat: $hasCat, '
        'confidence: $confidenceText, '
        'boundingBoxes: ${boundingBoxes.length}, '
        'processingTime: $processingTimeText'
        '}';
  }
}

class BoundingBox extends Equatable {
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

  // JSON serialization
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
        'x: $x, y: $y, '
        'width: $width, height: $height, '
        'label: $label, '
        'confidence: ${labelConfidence?.toStringAsFixed(2)}'
        '}';
  }
}
