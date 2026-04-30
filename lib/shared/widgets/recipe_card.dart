import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/recipes/domain/entities/recipe.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onBookmarkTap,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;

  // Warm placeholder backgrounds cycling by recipe id
  static const _placeholderColors = [
    Color(0xFFFFE8D6),
    Color(0xFFFFD4B8),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3EE),
    Color(0xFFE3F2FD),
  ];
  static const _placeholderEmojis = ['🍝', '🥗', '🍜', '🍕', '🥩', '🥣'];

  Color get _placeholderColor =>
      _placeholderColors[recipe.id % _placeholderColors.length];
  String get _placeholderEmoji =>
      _placeholderEmojis[recipe.id % _placeholderEmojis.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.06, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  // ── Image ──────────────────────────────────────────────────────────────────

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: recipe.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                    fadeInDuration: const Duration(milliseconds: 300),
                  )
                : _imagePlaceholder(),
          ),
          // Difficulty badge
          Positioned(
            bottom: 8,
            left: 8,
            child: _DifficultyBadge(minutes: recipe.readyInMinutes),
          ),
          // Bookmark button
          if (onBookmarkTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: _BookmarkButton(
                isSaved: recipe.isSaved,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onBookmarkTap!();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: _placeholderColor,
        child: Center(
          child: Text(_placeholderEmoji, style: const TextStyle(fontSize: 40)),
        ),
      );

  // ── Info ───────────────────────────────────────────────────────────────────

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: AppTypography.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _InfoChip(icon: '⏱', value: '${recipe.readyInMinutes} min'),
              const SizedBox(width: 8),
              if (recipe.calories > 0)
                _InfoChip(icon: '🔥', value: '${recipe.calories.toInt()} kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.isSaved, required this.onTap});
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Container(
          key: ValueKey(isSaved),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 18,
            color: isSaved ? AppColors.primary : AppColors.outline,
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.minutes});
  final int minutes;

  String get _label {
    if (minutes <= 20) return 'Easy';
    if (minutes <= 45) return 'Medium';
    return 'Hard';
  }

  Color get _bg {
    if (minutes <= 20) return const Color(0xFFE8F5E9);
    if (minutes <= 45) return const Color(0xFFFFF3EE);
    return const Color(0xFFFFDAD6);
  }

  Color get _text {
    if (minutes <= 20) return const Color(0xFF2C694E);
    if (minutes <= 45) return AppColors.primary;
    return const Color(0xFFBA1A1A);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child:
          Text(_label, style: AppTypography.labelSmall.copyWith(color: _text)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.value});
  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(value,
            style: AppTypography.statsStyle
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
