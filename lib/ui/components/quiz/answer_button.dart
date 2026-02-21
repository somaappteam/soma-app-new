// lib/ui/components/quiz/answer_button.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/radii.dart';

enum AnswerVisualState { idle, selected, correct, wrong }

class AnswerButton extends StatefulWidget {
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

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != AnswerVisualState.wrong && widget.state == AnswerVisualState.wrong) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Color get _border {
    switch (widget.state) {
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
    switch (widget.state) {
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
    switch (widget.state) {
      case AnswerVisualState.correct:
        return Icons.check_circle_rounded;
      case AnswerVisualState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  Color get _iconColor {
    switch (widget.state) {
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
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Shake logic: 3 full sine waves
        final dx = math.sin(_shakeController.value * math.pi * 6) * 6;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: InkWell(
        onTap: widget.enabled ? widget.onTap : null,
        borderRadius: AppRadii.br16,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: AppRadii.br16,
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(widget.label, style: AppTextStyles.body)),
              if (_icon != null) ...[
                const SizedBox(width: 10),
                Icon(_icon, color: _iconColor, size: 20),
              ] else if (widget.state == AnswerVisualState.selected) ...[
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
      ),
    );
  }
}
