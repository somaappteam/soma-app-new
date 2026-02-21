// lib/ui/components/common/focus_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

enum LearningFocus { mix, vocabulary, sentences }

extension LearningFocusLabel on LearningFocus {
  String get label {
    switch (this) {
      case LearningFocus.mix:
        return 'Mix';
      case LearningFocus.vocabulary:
        return 'Vocabulary';
      case LearningFocus.sentences:
        return 'Sentences';
    }
  }
}

/// Tiny chip shown under Continue: "Focus: Mix ▾"
class FocusChip extends StatefulWidget {
  const FocusChip({super.key, required this.focus, required this.onTap});

  final LearningFocus focus;
  final VoidCallback onTap;

  @override
  State<FocusChip> createState() => _FocusChipState();
}

class _FocusChipState extends State<FocusChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? AppMotion.pressScale : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: _pressed ? AppMotion.tapDown : AppMotion.tapUp,
        curve: _pressed ? Curves.easeOutCubic : AppMotion.bounceOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panel2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Focus: ', style: AppTextStyles.small),
              Text(
                widget.focus.label,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
