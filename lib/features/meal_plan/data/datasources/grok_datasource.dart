import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class GrokMealPlan {
  const GrokMealPlan({required this.days});
  final List<GrokDay> days;
}

class GrokDay {
  const GrokDay({required this.day, required this.meals});
  final String day;
  final List<GrokMeal> meals;
}

class GrokMeal {
  const GrokMeal({
    required this.type,
    required this.name,
    required this.calories,
  });
  final String type;
  final String name;
  final double calories;
}

/// Calls xAI Grok via the OpenAI-compatible Chat Completions API.
///
/// ⚠️  Your .env must contain:  GROK_API_KEY=xai-xxxxxxxxxxxx
///     xAI keys start with "xai-". Get one at https://console.x.ai
///     Do NOT paste your Gemini/Google key (starts with "AI") here.
class GrokDatasource {
  const GrokDatasource(this._dio);
  final Dio _dio;

  Future<GrokMealPlan> generateMealPlan({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    required List<String> dietaryPrefs,
  }) async {
    final key = AppConstants.grokApiKey;

    // ── Key validation guard ──────────────────────────────────────────────
    // Catches the common mistake of pasting a Gemini key (starts with "AI")
    // or a Spoonacular key, or leaving the placeholder value.
    if (key.isEmpty || key == 'your_grok_api_key_here') {
      throw Exception(
        'GROK_API_KEY is missing in your .env file.\n'
        'Get your key at https://console.x.ai and set:\n'
        '  GROK_API_KEY=gsk-xxxxxxxxxxxx',
      );
    }
    if (!key.startsWith('gsk_')) {
      throw Exception(
        'GROK_API_KEY looks wrong — xAI keys start with "xai-".\n'
        'You may have pasted a Gemini key (starts with "AI") by mistake.\n'
        'Get your correct key at https://console.x.ai',
      );
    }

    final prompt = _buildPrompt(
      goal: goal,
      calorieTarget: calorieTarget,
      mealsPerDay: mealsPerDay,
      dietaryPrefs: dietaryPrefs,
    );

    try {
      final response = await _dio.post(
        '${AppConstants.grokBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional nutritionist. Always respond with valid JSON only. No markdown, no explanation, no code fences.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 2048,
        },
      );

      final rawText = _extractText(response.data);
      return _parse(rawText);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  // ── Prompt ────────────────────────────────────────────────────────────────

  String _buildPrompt({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    required List<String> dietaryPrefs,
  }) {
    final prefsText = dietaryPrefs.isEmpty
        ? 'no specific dietary restrictions'
        : dietaryPrefs.join(', ');

    final mealTypes = switch (mealsPerDay) {
      2 => ['lunch', 'dinner'],
      4 => ['breakfast', 'lunch', 'dinner', 'snacks'],
      _ => ['breakfast', 'lunch', 'dinner'],
    };

    return '''
Generate a 7-day meal plan:
- Goal: $goal
- Daily calories: $calorieTarget kcal
- Meals per day: $mealsPerDay (${mealTypes.join(', ')})
- Dietary preferences: $prefsText

Respond with ONLY this JSON structure, nothing else:
{"days":[{"day":"Monday","meals":[{"type":"breakfast","name":"Oatmeal with Berries","calories":380},{"type":"lunch","name":"Grilled Chicken Salad","calories":520},{"type":"dinner","name":"Salmon with Quinoa","calories":650}]}]}

Rules:
- All 7 days: Monday through Sunday
- Meal types must be exactly: ${mealTypes.join(', ')}
- Calories must be realistic integers
- Recipe names must be real, specific dishes
''';
  }

  // ── Response parsing ──────────────────────────────────────────────────────

  String _extractText(dynamic data) {
    try {
      final choices = data['choices'] as List;
      final message = choices.first['message'];
      return message['content'] as String;
    } catch (_) {
      throw Exception('Unexpected Grok response structure: $data');
    }
  }

  GrokMealPlan _parse(String rawText) {
    final cleaned =
        rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final daysJson = json['days'] as List;

      final days = daysJson.map((d) {
        final mealsJson = d['meals'] as List;
        final meals = mealsJson
            .map((m) => GrokMeal(
                  type: (m['type'] as String).toLowerCase().trim(),
                  name: m['name'] as String,
                  calories: (m['calories'] as num).toDouble(),
                ))
            .toList();
        return GrokDay(day: d['day'] as String, meals: meals);
      }).toList();

      return GrokMealPlan(days: days);
    } catch (e) {
      throw Exception('Failed to parse Grok response: $e\n\nRaw: $rawText');
    }
  }
}
