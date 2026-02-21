// lib/ui/components/vocab_modes/falling_words/falling_words_hud.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';

/// Compact HUD for Falling Words:
/// - Speed level
/// - Streak
/// - Freeze status (available/used)
class FallingWordsHud extends StatelessWidget {
  const FallingWordsHud({
    super.key,
    required this.streak,
    required this.speedLevel,
    required this.freezeUsed,
  });

  final int streak;
  final int speedLevel; // UI-only: 1..n
  final bool freezeUsed;

  Color get speedColor {
    if (speedLevel >= 5) return AppColors.danger;
    if (speedLevel >= 3) return AppColors.secondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          _Pill(
            icon: Icons.trending_up_rounded,
            label: 'Speed $speedLevel',
            color: speedColor,
          ),
          const SizedBox(width: AppSpacing.s8),
          _Pill(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak $streak',
            color: streak >= 5 ? AppColors.success : AppColors.primary,
          ),
          const Spacer(),
          _Pill(
            icon: Icons.ac_unit_rounded,
            label: freezeUsed ? 'Freeze used' : 'Freeze ready',
            color: freezeUsed ? AppColors.textMuted : AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
