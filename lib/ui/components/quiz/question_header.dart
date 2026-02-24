import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/quiz_step_model.dart';
import '../common/panel_card.dart';

class QuestionHeader extends StatelessWidget {
  const QuestionHeader({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
  });

  final QuizStep step;
  final int stepIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      child: Row(
        children: [
          const _TypeChip(label: 'Vocabulary', color: AppColors.success, icon: Icons.quiz_rounded),
          const SizedBox(width: AppSpacing.s12),
          _XpPill(xp: step.xpReward),
          const Spacer(),
          Text('${stepIndex + 1}/$totalSteps', style: AppTextStyles.small),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

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
          Text(label, style: AppTextStyles.small.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('+$xp', style: AppTextStyles.small.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
