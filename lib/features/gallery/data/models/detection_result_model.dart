import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class DetectionResultModel extends DetectionResult {
  const DetectionResultModel({
    required super.confidence,
    required super.label,
  });

  factory DetectionResultModel.fromJson(Map<String, dynamic> json) {
    return DetectionResultModel(
      confidence: json['confidence'] as double,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'label': label,
    };
  }
}