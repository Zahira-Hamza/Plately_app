import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/recipes/data/models/ingredient_model.dart';
import 'features/recipes/data/models/instruction_model.dart';
import 'features/recipes/data/models/recipe_model.dart';
import 'features/recipes/data/models/step_model.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  // ── Flutter binding ───────────────────────────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive initialisation ───────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Register Hive adapters (Module 3) ─────────────────────────────────────
  // Order matters: nested types (StepModel, IngredientModel, InstructionModel)
  // must be registered before the types that contain them (RecipeModel).
  if (!Hive.isAdapterRegistered(StepModelAdapter().typeId)) {
    Hive.registerAdapter(StepModelAdapter());
  }
  if (!Hive.isAdapterRegistered(IngredientModelAdapter().typeId)) {
    Hive.registerAdapter(IngredientModelAdapter());
  }
  if (!Hive.isAdapterRegistered(InstructionModelAdapter().typeId)) {
    Hive.registerAdapter(InstructionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(RecipeModelAdapter().typeId)) {
    Hive.registerAdapter(RecipeModelAdapter());
  }
  // TODO Module 4: Register MealPlanModelAdapter, MealPlanDayModelAdapter,
  //               MealItemModelAdapter here.

  // ── Open Hive boxes ───────────────────────────────────────────────────────
  await Future.wait([
    Hive.openBox(AppConstants.hiveRecipesBox),
    Hive.openBox(AppConstants.hiveMealPlanBox),
    Hive.openBox(AppConstants.hiveCacheBox),
  ]);

  // ── Dependency injection ──────────────────────────────────────────────────
  await di.init();

  // ── Launch ────────────────────────────────────────────────────────────────
  runApp(const App());
}
