// lib/ui/components/vocab_modes/survival_timer/survival_timer_hud.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';

/// Survival Timer HUD:
/// - Big time left
/// - Survived time
/// - Tiny delta popup (+2s / -3s) after answers
class SurvivalTimerHud extends StatelessWidget {
  const SurvivalTimerHud({
    super.key,
    required this.timeLeftSeconds,
    required this.survivedSeconds,
    required this.lastDeltaMs,
    required this.showDelta,
  });

  final double timeLeftSeconds;
  final double survivedSeconds;

  /// Positive (+2000) or negative (-3000)
  final int lastDeltaMs;

  /// Controller can pass `true` briefly after an answer
  final bool showDelta;

  Color get _timeColor {
    if (timeLeftSeconds <= 5) return AppColors.danger;
    if (timeLeftSeconds <= 10) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final timeText = timeLeftSeconds.toStringAsFixed(1);
    final survivedText = survivedSeconds.toStringAsFixed(0);

    final deltaSec = (lastDeltaMs / 1000.0).toStringAsFixed(0);
    final isPositive = lastDeltaMs > 0;

    return PanelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, color: _timeColor),
              const SizedBox(width: 8),
              Text(
                '$timeText s',
                style: AppTextStyles.subtitle.copyWith(color: _timeColor),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.s12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.panelBorder),
            ),
            child: Text('Survived $survivedText s', style: AppTextStyles.small),
          ),

          const Spacer(),

          AnimatedOpacity(
            opacity: showDelta ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.danger)
                    .withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: (isPositive ? AppColors.success : AppColors.danger)
                      .withOpacity(0.35),
                ),
              ),
              child: Text(
                '${isPositive ? '+' : ''}$deltaSec s',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
