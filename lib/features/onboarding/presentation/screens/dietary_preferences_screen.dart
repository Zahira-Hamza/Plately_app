import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../injection_container.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key, this.editMode = false});

  /// When true the screen is opened from Profile (not onboarding).
  /// "Continue" label becomes "Save Changes" and on save we pop instead of
  /// navigating to /home.
  final bool editMode;

  @override
  State<DietaryPreferencesScreen> createState() =>
      _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState
    extends State<DietaryPreferencesScreen> {
  static const _dietOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Halal',
    'None',
  ];

  static const _allergyOptions = [
    'Nuts',
    'Shellfish',
    'Eggs',
    'Soy',
    'Wheat',
  ];

  final Set<String> _selectedDiets = {};
  final Set<String> _selectedAllergies = {};

  bool get _canContinue => _selectedDiets.isNotEmpty;

  void _toggleDiet(String value) {
    setState(() {
      if (value == 'None') {
        _selectedDiets
          ..clear()
          ..add('None');
      } else {
        _selectedDiets.remove('None');
        if (_selectedDiets.contains(value)) {
          _selectedDiets.remove(value);
        } else {
          _selectedDiets.add(value);
        }
      }
    });
  }

  void _toggleAllergy(String value) => setState(() {
        if (_selectedAllergies.contains(value)) {
          _selectedAllergies.remove(value);
        } else {
          _selectedAllergies.add(value);
        }
      });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is PreferencesSaved) {
            if (widget.editMode) {
              context.pop();
            } else {
              context.go('/home');
            }
          }
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.editMode
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.textPrimary, size: 28),
                onPressed: () => context.pop(),
              ),
              title: Text('Edit Preferences',
                  style: AppTypography.titleLarge),
            )
          : null,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(child: _buildScrollContent()),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Scrollable content ─────────────────────────────────────────────────────

  Widget _buildScrollContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.editMode) ...[
            Text('What are your\npreferences?',
                style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            Text(
              "We'll personalise your experience",
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
          ],

          // ── Diet section ─────────────────────────────────────────────────
          _SectionLabel(label: 'Diet'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietOptions
                .map((d) => _PreferenceChip(
                      label: d,
                      isSelected: _selectedDiets.contains(d),
                      onTap: () => _toggleDiet(d),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),

          // ── Allergies section ─────────────────────────────────────────────
          _SectionLabel(label: 'Allergies'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergyOptions
                .map((a) => _PreferenceChip(
                      label: a,
                      isSelected: _selectedAllergies.contains(a),
                      onTap: () => _toggleAllergy(a),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Bottom actions ─────────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final isLoading = state is OnboardingChecking;
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canContinue && !isLoading
                      ? () => context
                          .read<OnboardingCubit>()
                          .savePreferencesAndComplete(
                            preferences: _selectedDiets.toList(),
                            allergies: _selectedAllergies.toList(),
                          )
                      : null,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.editMode ? 'Save Changes' : 'Continue'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                widget.editMode ? context.pop() : context.go('/home'),
            child: Text(
              'Skip for now',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.08 * 14,
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color:
                isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
