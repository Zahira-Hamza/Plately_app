// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

class StepModelAdapter extends TypeAdapter<StepModel> {
  @override
  final int typeId = 3;

  @override
  StepModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepModel(
      number: (fields[0] as num).toInt(),
      step: fields[1] as String,
      lengthMinutes: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, StepModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.step)
      ..writeByte(2)
      ..write(obj.lengthMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
