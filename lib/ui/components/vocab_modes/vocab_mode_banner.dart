// lib/ui/components/vocab_modes/vocab_mode_banner.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../common/panel_card.dart';
import 'vocab_mode_type.dart';

class VocabModeBanner extends StatelessWidget {
  const VocabModeBanner({super.key, required this.mode});

  final VocabGameMode mode;

  IconData get _icon {
    switch (mode) {
      case VocabGameMode.classicMcq:
        return Icons.school_rounded;
      case VocabGameMode.survivalTimer:
        return Icons.timer_rounded;
      case VocabGameMode.rapidChain:
        return Icons.bolt_rounded;
      case VocabGameMode.fallingWords:
        return Icons.arrow_downward_rounded;
    }
  }

  Color get _accent {
    switch (mode) {
      case VocabGameMode.classicMcq:
        return AppColors.primary;
      case VocabGameMode.survivalTimer:
        return AppColors.success;
      case VocabGameMode.rapidChain:
        return AppColors.secondary;
      case VocabGameMode.fallingWords:
        return AppColors.warning;
    }
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.30)),
            ),
            child: Icon(_icon, color: _accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.title, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(mode.subtitle, style: AppTextStyles.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
