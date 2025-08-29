import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';

class CatPhoto {
  final String id;
  final String path;
  final String name;
  final DateTime dateAdded;
  final DetectionResult detectionResult;
  final PhotoMetadata metadata;

  const CatPhoto({
    required this.id,
    required this.path,
    required this.name,
    required this.dateAdded,
    required this.detectionResult,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    path,
    name,
    dateAdded,
    detectionResult,
    metadata,
  ];

  CatPhoto copyWith({
    String? id,
    String? path,
    String? name,
    DateTime? dateAdded,
    DetectionResult? detectionResult,
    PhotoMetadata? metadata,
  }) {
    return CatPhoto(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      dateAdded: dateAdded ?? this.dateAdded,
      detectionResult: detectionResult ?? this.detectionResult,
      metadata: metadata ?? this.metadata,
    );
  }
}
