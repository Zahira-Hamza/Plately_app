import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/recipe_card.dart';
import '../../../../shared/widgets/shimmer/recipe_shimmers.dart';
import '../cubits/recipe_search_cubit.dart';

/// SearchScreen owns its [RecipeSearchCubit] via [BlocProvider].
///
/// The fix for ProviderNotFoundException: the [StatefulWidget] splits into
/// an outer shell that provides the cubit, and an inner [_SearchBody] that
/// reads it — so every `context.read<RecipeSearchCubit>()` call is always
/// made from a context that is a descendant of the [BlocProvider].
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeSearchCubit>(),
      child: const _SearchBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner stateful widget — context is always below BlocProvider
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _activeFilter;

  static const _filters = ['All', 'Quick <30min', 'Healthy', 'Vegetarian'];
  static const _popularSearches = [
    'Pasta 🍝', 'Chicken 🍗', 'Salad 🥗', 'Soup 🥣'
  ];
  static const _prefsKey = 'recent_searches';

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _recentSearches = prefs.getStringList(_prefsKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [
      query,
      ..._recentSearches.where((s) => s != query),
    ].take(5).toList();
    await prefs.setStringList(_prefsKey, updated);
    if (!mounted) return;
    setState(() => _recentSearches = updated);
  }

  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _recentSearches.where((s) => s != query).toList();
    await prefs.setStringList(_prefsKey, updated);
    if (!mounted) return;
    setState(() => _recentSearches = updated);
  }

  // ── All cubit reads use THIS context — safely below BlocProvider ──────────

  void _onSearchChanged(String value) {
    context.read<RecipeSearchCubit>().search(
          value,
          diet: _dietFromFilter(_activeFilter),
        );
    if (value.isNotEmpty) _saveRecentSearch(value);
  }

  void _applyFilter(String filter) {
    setState(() => _activeFilter = filter == 'All' ? null : filter);
    if (_controller.text.isNotEmpty) {
      context.read<RecipeSearchCubit>().search(
            _controller.text,
            diet: _dietFromFilter(_activeFilter),
          );
    }
  }

  String? _dietFromFilter(String? filter) => switch (filter) {
        'Vegetarian' => 'vegetarian',
        'Healthy' => 'whole30',
        _ => null,
      };

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Recipes', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          _SearchBar(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onClear: () {
              _controller.clear();
              context.read<RecipeSearchCubit>().clearSearch();
            },
          ),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final isActive =
              (f == 'All' && _activeFilter == null) || f == _activeFilter;
          return _FilterChip(
            label: f,
            isActive: isActive,
            onTap: () => _applyFilter(f),
          );
        },
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return BlocBuilder<RecipeSearchCubit, RecipeSearchState>(
      builder: (context, state) {
        if (state is RecipeSearchInitial) return _buildDefaultState();
        if (state is RecipeSearchLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: ShimmerRecipeGrid(),
          );
        }
        if (state is RecipeSearchLoaded) return _buildResults(state.recipes);
        if (state is RecipeSearchEmpty) return _buildNoResults(state.query);
        if (state is RecipeSearchError) return _buildError(state.message);
        return const SizedBox.shrink();
      },
    );
  }

  // ── Default state ──────────────────────────────────────────────────────────

  Widget _buildDefaultState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Text('Recent Searches',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map((s) => _RecentChip(
                        label: s,
                        onTap: () {
                          _controller.text = s;
                          _onSearchChanged(s);
                        },
                        onRemove: () => _removeRecentSearch(s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          Text('Popular Searches',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches
                .map((s) => _PopularChip(
                      label: s,
                      onTap: () {
                        _controller.text = s;
                        _onSearchChanged(s);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Results ────────────────────────────────────────────────────────────────

  Widget _buildResults(List<dynamic> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            '${recipes.length} recipes found',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, i) => RecipeCard(
              recipe: recipes[i],
              onTap: () => context.push('/recipe/${recipes[i].id}'),
            ),
          ),
        ),
      ],
    );
  }

  // ── No results ─────────────────────────────────────────────────────────────

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No recipes found for "$query"',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different ingredients or check spelling',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Try AI Suggestions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _onSearchChanged(_controller.text),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.outline),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.outline, size: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.outline, size: 20),
                  onPressed: onClear,
                )
              : const Icon(Icons.mic_rounded,
                  color: AppColors.outline, size: 20),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded,
                size: 14, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelMedium),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.tagBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
