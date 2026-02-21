// lib/ui/components/quiz/answer_button.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/radii.dart';

enum AnswerVisualState { idle, selected, correct, wrong }

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final AnswerVisualState state;
  final VoidCallback onTap;
  final bool enabled;

  Color get _border {
    switch (state) {
      case AnswerVisualState.idle:
        return AppColors.panelBorder;
      case AnswerVisualState.selected:
        return AppColors.primary.withOpacity(0.55);
      case AnswerVisualState.correct:
        return AppColors.success.withOpacity(0.65);
      case AnswerVisualState.wrong:
        return AppColors.danger.withOpacity(0.65);
    }
  }

  Color get _bg {
    switch (state) {
      case AnswerVisualState.idle:
        return AppColors.panel;
      case AnswerVisualState.selected:
        return AppColors.primary.withOpacity(0.16);
      case AnswerVisualState.correct:
        return AppColors.success.withOpacity(0.14);
      case AnswerVisualState.wrong:
        return AppColors.danger.withOpacity(0.14);
    }
  }

  IconData? get _icon {
    switch (state) {
      case AnswerVisualState.correct:
        return Icons.check_circle_rounded;
      case AnswerVisualState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  Color get _iconColor {
    switch (state) {
      case AnswerVisualState.correct:
        return AppColors.success;
      case AnswerVisualState.wrong:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppRadii.br16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: AppRadii.br16,
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            if (_icon != null) ...[
              const SizedBox(width: 10),
              Icon(_icon, color: _iconColor, size: 20),
            ] else if (state == AnswerVisualState.selected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.radio_button_checked,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
