// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instruction_model.dart';

class InstructionModelAdapter extends TypeAdapter<InstructionModel> {
  @override
  final int typeId = 2;

  @override
  InstructionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstructionModel(
      name: fields[0] as String,
      steps: (fields[1] as List).cast<StepModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, InstructionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstructionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
