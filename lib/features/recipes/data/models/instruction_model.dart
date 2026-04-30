import 'package:hive_flutter/hive_flutter.dart';
import 'step_model.dart';

part 'instruction_model.g.dart';

@HiveType(typeId: 2)
class InstructionModel extends HiveObject {
  InstructionModel({
    required this.name,
    required this.steps,
  });

  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<StepModel> steps;

  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final steps = (rawSteps is List)
        ? rawSteps
            .map((s) => StepModel.fromJson(s as Map<String, dynamic>))
            .toList()
        : <StepModel>[];

    return InstructionModel(
      name: (json['name'] as String?) ?? '',
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}
