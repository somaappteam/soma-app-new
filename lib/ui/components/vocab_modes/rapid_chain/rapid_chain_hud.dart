// lib/ui/components/vocab_modes/rapid_chain/rapid_chain_hud.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';

/// HUD row for Rapid Chain mode:
/// - Combo pill
/// - Speed indicator
/// - Streak counter
class RapidChainHud extends StatelessWidget {
  const RapidChainHud({
    super.key,
    required this.combo,
    required this.streak,
    required this.pacingMs,
    this.showSpeedUpHint = false,
  });

  final int combo;
  final int streak;
  final int pacingMs;
  final bool showSpeedUpHint;

  String get speedLabel {
    // Just a simple mapping for UI readability
    if (pacingMs <= 460) return 'INSANE';
    if (pacingMs <= 520) return 'FAST';
    if (pacingMs <= 620) return 'NORMAL';
    return 'WARMUP';
  }

  Color get speedColor {
    if (pacingMs <= 460) return AppColors.danger;
    if (pacingMs <= 520) return AppColors.secondary;
    if (pacingMs <= 620) return AppColors.primary;
    return AppColors.textSecondary;
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
            icon: Icons.bolt_rounded,
            label: 'COMBO x$combo',
            color: combo >= 5 ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.s8),
          _Pill(
            icon: Icons.speed_rounded,
            label: speedLabel,
            color: speedColor,
          ),
          const Spacer(),
          Text('Streak $streak', style: AppTextStyles.small),
          if (showSpeedUpHint) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.trending_up_rounded,
              size: 16,
              color: AppColors.success,
            ),
          ],
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
