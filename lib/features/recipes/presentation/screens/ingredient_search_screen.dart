import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/recipe_card.dart';
import '../../../../shared/widgets/shimmer/recipe_shimmers.dart';
import '../cubits/recipe_search_cubit.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  State<IngredientSearchScreen> createState() =>
      _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _ingredients = [];

  void _addIngredient() {
    final value = _controller.text.trim();
    if (value.isEmpty || _ingredients.contains(value)) return;
    setState(() => _ingredients.add(value));
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _removeIngredient(String item) =>
      setState(() => _ingredients.remove(item));

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeSearchCubit>(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textPrimary, size: 28),
              onPressed: () => context.pop(),
            ),
            title: Text("What's in your fridge? 🥦",
                style: AppTypography.titleLarge),
          ),
          body: _Body(
            controller: _controller,
            focusNode: _focusNode,
            ingredients: _ingredients,
            onAdd: _addIngredient,
            onRemove: _removeIngredient,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.controller,
    required this.focusNode,
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> ingredients;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Text(
            'Add ingredients and we\'ll find matching recipes',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),

        // ── Input row ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTypography.bodyMedium,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  decoration: InputDecoration(
                    hintText: 'e.g. chicken, garlic, tomato...',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.outline),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onAdd,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Chips ──────────────────────────────────────────────────────────
        if (ingredients.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Your ingredients',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredients
                  .map((ing) => _IngredientChip(
                        label: ing,
                        onRemove: () => onRemove(ing),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Find button ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 18),
              label: const Text('Find Recipes'),
              onPressed: ingredients.isEmpty
                  ? null
                  : () => context
                      .read<RecipeSearchCubit>()
                      .searchByIngredients(ingredients),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Results ────────────────────────────────────────────────────────
        BlocBuilder<RecipeSearchCubit, RecipeSearchState>(
          builder: (context, state) {
            if (state is RecipeSearchInitial) {
              return const SizedBox.shrink();
            }
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Divider(),
                  if (state is RecipeSearchLoading)
                    ...List.generate(
                        3, (_) => const ShimmerRecipeListItem())
                  else if (state is RecipeSearchLoaded)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: state.recipes.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: RecipeCard(
                            recipe: state.recipes[i],
                            onTap: () => context
                                .push('/recipe/${state.recipes[i].id}'),
                          ),
                        ),
                      ),
                    )
                  else if (state is RecipeSearchEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No recipes found for those ingredients.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (state is RecipeSearchError)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(state.message,
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.primary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.outlineVariant, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Recipes for your ingredients',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.outline),
            ),
          ),
          const Expanded(
              child: Divider(color: AppColors.outlineVariant, height: 1)),
        ],
      ),
    );
  }
}
