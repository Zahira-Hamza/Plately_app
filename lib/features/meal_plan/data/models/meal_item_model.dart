import 'package:hive_flutter/hive_flutter.dart';

part 'meal_item_model.g.dart';

@HiveType(typeId: 6)
class MealItemModel extends HiveObject {
  MealItemModel({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.calories,
    required this.addedAt,
  });

  @HiveField(0)
  final int recipeId;

  @HiveField(1)
  final String recipeName;

  @HiveField(2)
  final String recipeImage;

  @HiveField(3)
  final double calories;

  @HiveField(4)
  final DateTime addedAt;

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'recipeName': recipeName,
        'recipeImage': recipeImage,
        'calories': calories,
        'addedAt': addedAt.toIso8601String(),
      };

  factory MealItemModel.fromJson(Map<String, dynamic> json) =>
      MealItemModel(
        recipeId: (json['recipeId'] as num).toInt(),
        recipeName: json['recipeName'] as String,
        recipeImage: json['recipeImage'] as String? ?? '',
        calories: (json['calories'] as num).toDouble(),
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
