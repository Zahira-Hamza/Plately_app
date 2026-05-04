// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item_model.dart';

class MealItemModelAdapter extends TypeAdapter<MealItemModel> {
  @override
  final int typeId = 6;

  @override
  MealItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealItemModel(
      recipeId: (fields[0] as num).toInt(),
      recipeName: fields[1] as String,
      recipeImage: fields[2] as String,
      calories: (fields[3] as num).toDouble(),
      addedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.recipeId)
      ..writeByte(1)
      ..write(obj.recipeName)
      ..writeByte(2)
      ..write(obj.recipeImage)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
