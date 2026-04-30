import 'package:hive_flutter/hive_flutter.dart';
import 'ingredient_model.dart';
import 'instruction_model.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  RecipeModel({
    required this.id,
    required this.title,
    required this.image,
    required this.imageType,
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
    required this.extendedIngredients,
    required this.analyzedInstructions,
    this.isSaved = false,
    this.cachedAt,
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final String imageType;

  @HiveField(4)
  final int readyInMinutes;

  @HiveField(5)
  final int servings;

  @HiveField(6)
  final double calories;

  @HiveField(7)
  final double protein;

  @HiveField(8)
  final double carbs;

  @HiveField(9)
  final double fat;

  @HiveField(10)
  final String summary;

  @HiveField(11)
  final List<String> dishTypes;

  @HiveField(12)
  final List<String> diets;

  @HiveField(13)
  final List<String> cuisines;

  @HiveField(14)
  final List<IngredientModel> extendedIngredients;

  @HiveField(15)
  final List<InstructionModel> analyzedInstructions;

  /// Local-only flag — not from the API.
  @HiveField(16)
  bool isSaved;

  /// When this model was cached (used for TTL checks).
  @HiveField(17)
  final DateTime? cachedAt;

  // ──────────────────────────────────────────────────────────────────────────
  // JSON deserialization
  // ──────────────────────────────────────────────────────────────────────────

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Nutrition is nested — parse nutrients array if present.
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    final nutrition = json['nutrition'];
    if (nutrition is Map) {
      final nutrients = nutrition['nutrients'];
      if (nutrients is List) {
        for (final n in nutrients) {
          if (n is! Map) continue;
          final name = (n['name'] as String?)?.toLowerCase() ?? '';
          final amount = (n['amount'] as num?)?.toDouble() ?? 0.0;
          switch (name) {
            case 'calories':
              calories = amount;
            case 'protein':
              protein = amount;
            case 'carbohydrates':
              carbs = amount;
            case 'fat':
              fat = amount;
          }
        }
      }
    }

    // Ingredients
    final rawIngredients = json['extendedIngredients'];
    final ingredients = (rawIngredients is List)
        ? rawIngredients
            .map((i) => IngredientModel.fromJson(i as Map<String, dynamic>))
            .toList()
        : <IngredientModel>[];

    // Instructions
    final rawInstructions = json['analyzedInstructions'];
    final instructions = (rawInstructions is List)
        ? rawInstructions
            .map((i) =>
                InstructionModel.fromJson(i as Map<String, dynamic>))
            .toList()
        : <InstructionModel>[];

    return RecipeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      imageType: (json['imageType'] as String?) ?? 'jpg',
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      summary: (json['summary'] as String?) ?? '',
      dishTypes: _toStringList(json['dishTypes']),
      diets: _toStringList(json['diets']),
      cuisines: _toStringList(json['cuisines']),
      extendedIngredients: ingredients,
      analyzedInstructions: instructions,
      cachedAt: DateTime.now(),
    );
  }

  /// Deserializes a result from `GET /recipes/complexSearch`.
  /// The search endpoint returns a lighter payload — nutrition is nested
  /// inside `nutrition.nutrients` when `addRecipeNutrition=true`.
  factory RecipeModel.fromSearchJson(Map<String, dynamic> json) =>
      RecipeModel.fromJson(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'imageType': imageType,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'nutrition': {
          'nutrients': [
            {'name': 'Calories', 'amount': calories},
            {'name': 'Protein', 'amount': protein},
            {'name': 'Carbohydrates', 'amount': carbs},
            {'name': 'Fat', 'amount': fat},
          ],
        },
        'summary': summary,
        'dishTypes': dishTypes,
        'diets': diets,
        'cuisines': cuisines,
        'extendedIngredients':
            extendedIngredients.map((i) => i.toJson()).toList(),
        'analyzedInstructions':
            analyzedInstructions.map((i) => i.toJson()).toList(),
      };

  /// Returns a copy with [isSaved] toggled and optional field overrides.
  RecipeModel copyWith({bool? isSaved}) => RecipeModel(
        id: id,
        title: title,
        image: image,
        imageType: imageType,
        readyInMinutes: readyInMinutes,
        servings: servings,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        summary: summary,
        dishTypes: dishTypes,
        diets: diets,
        cuisines: cuisines,
        extendedIngredients: extendedIngredients,
        analyzedInstructions: analyzedInstructions,
        isSaved: isSaved ?? this.isSaved,
        cachedAt: cachedAt,
      );

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  static List<String> _toStringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  /// Returns true if this cache entry is older than [maxAge] (default 1 hour).
  bool isCacheExpired({Duration maxAge = const Duration(hours: 1)}) {
    if (cachedAt == null) return true;
    return DateTime.now().difference(cachedAt!) > maxAge;
  }
}
