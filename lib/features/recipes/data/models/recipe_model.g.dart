// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build --delete-conflicting-outputs

part of 'recipe_model.dart';

class RecipeModelAdapter extends TypeAdapter<RecipeModel> {
  @override
  final int typeId = 0;

  @override
  RecipeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeModel(
      id: (fields[0] as num).toInt(),
      title: fields[1] as String,
      image: fields[2] as String,
      imageType: fields[3] as String,
      readyInMinutes: (fields[4] as num).toInt(),
      servings: (fields[5] as num).toInt(),
      calories: (fields[6] as num).toDouble(),
      protein: (fields[7] as num).toDouble(),
      carbs: (fields[8] as num).toDouble(),
      fat: (fields[9] as num).toDouble(),
      summary: fields[10] as String,
      dishTypes: (fields[11] as List).cast<String>(),
      diets: (fields[12] as List).cast<String>(),
      cuisines: (fields[13] as List).cast<String>(),
      extendedIngredients:
          (fields[14] as List).cast<IngredientModel>(),
      analyzedInstructions:
          (fields[15] as List).cast<InstructionModel>(),
      isSaved: fields[16] as bool,
      cachedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.imageType)
      ..writeByte(4)
      ..write(obj.readyInMinutes)
      ..writeByte(5)
      ..write(obj.servings)
      ..writeByte(6)
      ..write(obj.calories)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.carbs)
      ..writeByte(9)
      ..write(obj.fat)
      ..writeByte(10)
      ..write(obj.summary)
      ..writeByte(11)
      ..write(obj.dishTypes)
      ..writeByte(12)
      ..write(obj.diets)
      ..writeByte(13)
      ..write(obj.cuisines)
      ..writeByte(14)
      ..write(obj.extendedIngredients)
      ..writeByte(15)
      ..write(obj.analyzedInstructions)
      ..writeByte(16)
      ..write(obj.isSaved)
      ..writeByte(17)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
