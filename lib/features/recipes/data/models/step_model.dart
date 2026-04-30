import 'package:hive_flutter/hive_flutter.dart';

part 'step_model.g.dart';

@HiveType(typeId: 3)
class StepModel extends HiveObject {
  StepModel({
    required this.number,
    required this.step,
    this.lengthMinutes,
  });

  @HiveField(0)
  final int number;

  @HiveField(1)
  final String step;

  /// Cooking duration for this step in minutes, if the API provides it.
  @HiveField(2)
  final int? lengthMinutes;

  factory StepModel.fromJson(Map<String, dynamic> json) {
    // Spoonacular wraps duration in a nested 'length' object.
    int? length;
    final rawLength = json['length'];
    if (rawLength is Map) {
      final unit = (rawLength['unit'] as String?)?.toLowerCase() ?? '';
      final number = (rawLength['number'] as num?)?.toInt() ?? 0;
      // Convert hours → minutes if needed.
      length = unit == 'hours' ? number * 60 : number;
    }
    return StepModel(
      number: (json['number'] as num?)?.toInt() ?? 0,
      step: (json['step'] as String?) ?? '',
      lengthMinutes: length,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'step': step,
        'length': lengthMinutes == null
            ? null
            : {'number': lengthMinutes, 'unit': 'minutes'},
      };
}
