import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/meal_plan/data/models/meal_item_model.dart';
import 'features/meal_plan/data/models/meal_plan_day_model.dart';
import 'features/meal_plan/data/models/meal_plan_model.dart';
import 'features/recipes/data/models/ingredient_model.dart';
import 'features/recipes/data/models/instruction_model.dart';
import 'features/recipes/data/models/recipe_model.dart';
import 'features/recipes/data/models/step_model.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load .env FIRST — before anything reads AppConstants ─────────────────
  await dotenv.load(fileName: '.env');

  // ── Hive ─────────────────────────────────────────────────────────────────
  await Hive.initFlutter();

  // Module 3 adapters — register in dependency order
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(StepModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(IngredientModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(InstructionModelAdapter());
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(RecipeModelAdapter());

  // Module 4 adapters
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(MealItemModelAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(MealPlanDayModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(MealPlanModelAdapter());

  // ── Open Hive boxes ───────────────────────────────────────────────────────
  await Future.wait([
    Hive.openBox(AppConstants.hiveRecipesBox),
    Hive.openBox(AppConstants.hiveMealPlanBox),
    Hive.openBox(AppConstants.hiveCacheBox),
  ]);

  // ── DI ───────────────────────────────────────────────────────────────────
  await di.init();

  runApp(const App());
}
