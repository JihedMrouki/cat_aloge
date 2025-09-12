import 'package:equatable/equatable.dart';

class FavoriteCat extends Equatable {
  final String id;
  final String catPhotoId;
  final String name;
  final String imagePath;
  final DateTime dateAdded;
  final String? notes;

  const FavoriteCat({
    required this.id,
    required this.catPhotoId,
    required this.name,
    required this.imagePath,
    required this.dateAdded,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    catPhotoId,
    name,
    imagePath,
    dateAdded,
    notes,
  ];

  FavoriteCat copyWith({
    String? id,
    String? catPhotoId,
    String? name,
    String? imagePath,
    DateTime? dateAdded,
    String? notes,
  }) {
    return FavoriteCat(
      id: id ?? this.id,
      catPhotoId: catPhotoId ?? this.catPhotoId,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
    );
  }
}
