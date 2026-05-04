import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base shimmer block helper
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

Widget _shimmerWrap({required Widget child}) => Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Recipe card shimmer
// The overflow was caused by the inner Column having no size constraint —
// ClipRect + overflow hidden stops the 6px bleed.
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerRecipeCard extends StatelessWidget {
  const ShimmerRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColors.cardSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,  // ← key fix: don't expand beyond content
            children: [
              // Image area
              _ShimmerBox(
                width: double.infinity,
                height: 120,
                borderRadius: 0, // ClipRRect handles corner radius
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ShimmerBox(
                        width: double.infinity, height: 16, borderRadius: 4),
                    const SizedBox(height: 6),
                    _ShimmerBox(width: 100, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recipe grid shimmer (2-column)
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerRecipeGrid extends StatelessWidget {
  const ShimmerRecipeGrid({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerRecipeCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card shimmer
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerHeroCard extends StatelessWidget {
  const ShimmerHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: _ShimmerBox(
        width: double.infinity,
        height: 200,
        borderRadius: 16,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day card shimmer
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerDayCard extends StatelessWidget {
  const ShimmerDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: _ShimmerBox(width: 88, height: 110, borderRadius: 16),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recipe list item shimmer
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerRecipeListItem extends StatelessWidget {
  const ShimmerRecipeListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _ShimmerBox(width: 80, height: 80, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ShimmerBox(
                      width: double.infinity, height: 16, borderRadius: 4),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 120, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recipe detail shimmer
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerRecipeDetail extends StatelessWidget {
  const ShimmerRecipeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: double.infinity, height: 280, borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                      width: double.infinity, height: 28, borderRadius: 6),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 180, height: 18, borderRadius: 6),
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ShimmerBox(
                            width: 72, height: 32, borderRadius: 999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(
                      4,
                      (_) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _ShimmerBox(
                              width: double.infinity,
                              height: 80,
                              borderRadius: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _ShimmerBox(
                              width: 80, height: 16, borderRadius: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(
                    5,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          _ShimmerBox(width: 40, height: 40, borderRadius: 8),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ShimmerBox(
                                width: double.infinity,
                                height: 16,
                                borderRadius: 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
