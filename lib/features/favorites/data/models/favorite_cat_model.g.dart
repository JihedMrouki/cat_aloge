// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_cat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteCatModelAdapter extends TypeAdapter<FavoriteCatModel> {
  @override
  final int typeId = 0;

  @override
  FavoriteCatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteCatModel(
      id: fields[0] as String,
      catPhotoId: fields[1] as String,
      name: fields[2] as String,
      imagePath: fields[3] as String,
      dateAdded: fields[4] as DateTime,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteCatModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.catPhotoId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.dateAdded)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteCatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteCatModel _$FavoriteCatModelFromJson(Map<String, dynamic> json) =>
    FavoriteCatModel(
      id: json['id'] as String,
      catPhotoId: json['catPhotoId'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$FavoriteCatModelToJson(FavoriteCatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'catPhotoId': instance.catPhotoId,
      'name': instance.name,
      'imagePath': instance.imagePath,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'notes': instance.notes,
    };
