// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_day_model.dart';

class MealPlanDayModelAdapter extends TypeAdapter<MealPlanDayModel> {
  @override
  final int typeId = 5;

  @override
  MealPlanDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlanDayModel(
      date: fields[0] as DateTime,
      breakfast: (fields[1] as List).cast<MealItemModel>(),
      lunch: (fields[2] as List).cast<MealItemModel>(),
      dinner: (fields[3] as List).cast<MealItemModel>(),
      snacks: (fields[4] as List).cast<MealItemModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanDayModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.breakfast)
      ..writeByte(2)
      ..write(obj.lunch)
      ..writeByte(3)
      ..write(obj.dinner)
      ..writeByte(4)
      ..write(obj.snacks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
