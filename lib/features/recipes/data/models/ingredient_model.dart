import 'package:hive_flutter/hive_flutter.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: 1)
class IngredientModel extends HiveObject {
  IngredientModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.image,
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String unit;

  /// Filename only (e.g. "flour.jpg") — prepend the Spoonacular CDN URL
  /// `https://spoonacular.com/cdn/ingredients_100x100/` to render it.
  @HiveField(4)
  final String image;

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: (json['unit'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'unit': unit,
        'image': image,
      };

  /// Full CDN URL for the ingredient thumbnail.
  String get imageUrl =>
      'https://spoonacular.com/cdn/ingredients_100x100/$image';
}
