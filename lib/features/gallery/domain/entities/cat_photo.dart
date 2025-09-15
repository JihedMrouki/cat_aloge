import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:equatable/equatable.dart';

class CatPhoto extends Equatable {
  final String id;
  final String path;
  final String fileName;
  final bool isFavorite;
  final DetectionResult? detectionResult;

  const CatPhoto({
    required this.id,
    required this.path,
    required this.fileName,
    required this.isFavorite,
    this.detectionResult,
  });

  CatPhoto copyWith({
    String? id,
    String? path,
    String? fileName,
    bool? isFavorite,
    DetectionResult? detectionResult,
  }) {
    return CatPhoto(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      isFavorite: isFavorite ?? this.isFavorite,
      detectionResult: detectionResult ?? this.detectionResult,
    );
  }

  @override
  List<Object?> get props => [id, path, fileName, isFavorite, detectionResult];
}