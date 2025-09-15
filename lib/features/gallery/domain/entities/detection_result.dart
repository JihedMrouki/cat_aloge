import 'package:equatable/equatable.dart';

class DetectionResult extends Equatable {
  final double confidence;
  final String label;

  const DetectionResult({required this.confidence, required this.label});

  @override
  List<Object?> get props => [confidence, label];
}