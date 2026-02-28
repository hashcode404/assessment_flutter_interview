// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectDataModelAdapter extends TypeAdapter<ProjectDataModel> {
  @override
  final int typeId = 0;

  @override
  ProjectDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectDataModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectDataModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
