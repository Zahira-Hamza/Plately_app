import 'package:equatable/equatable.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/instruction_model.dart';

/// Pure domain entity for a recipe.
/// No JSON annotations, no Hive annotations — safe to use in domain/presentation.
class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.summary,
    required this.dishTypes,
    required this.diets,
    required this.cuisines,
    required this.ingredients,
    required this.instructions,
    this.isSaved = false,
  });

  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String summary;
  final List<String> dishTypes;
  final List<String> diets;
  final List<String> cuisines;
  final List<IngredientModel> ingredients;
  final List<InstructionModel> instructions;
  final bool isSaved;

  Recipe copyWith({
    bool? isSaved,
    int? servings,
    List<IngredientModel>? ingredients,
  }) =>
      Recipe(
        id: id,
        title: title,
        image: image,
        readyInMinutes: readyInMinutes,
        servings: servings ?? this.servings,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        summary: summary,
        dishTypes: dishTypes,
        diets: diets,
        cuisines: cuisines,
        ingredients: ingredients ?? this.ingredients,
        instructions: instructions,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props => [id, title, isSaved, servings];
}
