// lib/ui/components/sentence_modes/speed_elimination/speed_elimination_hud.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';

class SpeedEliminationHud extends StatelessWidget {
  const SpeedEliminationHud({
    super.key,
    required this.timeLeftSeconds,
    required this.optionsLeft,
  });

  final double timeLeftSeconds;
  final int optionsLeft;

  Color get _timeColor {
    if (timeLeftSeconds <= 3) return AppColors.danger;
    if (timeLeftSeconds <= 6) return AppColors.warning;
    return AppColors.success;
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
          Icon(Icons.timer_rounded, color: _timeColor),
          const SizedBox(width: 8),
          Text(
            '${timeLeftSeconds.toStringAsFixed(1)}s',
            style: AppTextStyles.subtitle.copyWith(color: _timeColor),
          ),
          const SizedBox(width: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.panelBorder),
            ),
            child: Text(
              '$optionsLeft left',
              style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const Spacer(),
          Text('Eliminate wrongs', style: AppTextStyles.small),
        ],
      ),
    );
  }
}
