import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';

/// Caches [RecipeModel] instances in a Hive box to reduce API calls.
///
/// Each entry is stored under the recipe's integer id (as a string key).
/// Entries older than [_cacheTtl] are considered stale and will be ignored.
class RecipeLocalDatasource {
  const RecipeLocalDatasource(this._cacheBox);

  final Box _cacheBox;

  static const Duration _cacheTtl = Duration(hours: 1);

  // ──────────────────────────────────────────────────────────────────────────
  // Write
  // ──────────────────────────────────────────────────────────────────────────

  /// Stores [recipe] in the cache, overwriting any previous entry.
  Future<void> cacheRecipe(RecipeModel recipe) async {
    await _cacheBox.put(recipe.id.toString(), recipe.toJson());
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Read
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns the cached [RecipeModel] for [id], or `null` if:
  ///   - the entry does not exist, or
  ///   - the entry is older than [_cacheTtl].
  RecipeModel? getCachedRecipe(int id) {
    final raw = _cacheBox.get(id.toString());
    if (raw == null) return null;

    try {
      final model = RecipeModel.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
      return model.isCacheExpired(maxAge: _cacheTtl) ? null : model;
    } catch (_) {
      // Corrupt cache entry — treat as a miss.
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Maintenance
  // ──────────────────────────────────────────────────────────────────────────

  /// Removes all entries whose [RecipeModel.cachedAt] exceeds [_cacheTtl].
  Future<void> clearExpiredCache() async {
    final expiredKeys = <dynamic>[];

    for (final key in _cacheBox.keys) {
      final raw = _cacheBox.get(key);
      if (raw == null) continue;
      try {
        final model = RecipeModel.fromJson(
          Map<String, dynamic>.from(raw as Map),
        );
        if (model.isCacheExpired(maxAge: _cacheTtl)) {
          expiredKeys.add(key);
        }
      } catch (_) {
        expiredKeys.add(key); // Remove corrupt entries too.
      }
    }

    if (expiredKeys.isNotEmpty) {
      await _cacheBox.deleteAll(expiredKeys);
    }
  }

  /// Wipes the entire cache box.
  Future<void> clearAll() => _cacheBox.clear();
}
