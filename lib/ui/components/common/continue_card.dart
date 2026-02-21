// lib/ui/components/common/continue_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import 'focus_chip.dart';
import 'progress_bar.dart';

class ContinueCard extends StatefulWidget {
  const ContinueCard({
    super.key,
    required this.focus,
    required this.onTap,
    required this.onFocusTap,
    required this.progress, // 0..1
    required this.etaText, // e.g. "2 min"
  });

  final LearningFocus focus;
  final VoidCallback onTap;
  final VoidCallback onFocusTap;
  final double progress;
  final String etaText;

  @override
  State<ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<ContinueCard> {
  bool _pressed = false;

  String get _subtitle {
    switch (widget.focus) {
      case LearningFocus.mix:
        return 'Next: Sentence • ${widget.etaText}';
      case LearningFocus.vocabulary:
        return 'Next: Vocab • ${widget.etaText}';
      case LearningFocus.sentences:
        return 'Next: Sentence • ${widget.etaText}';
    }
  }

  IconData get _icon {
    switch (widget.focus) {
      case LearningFocus.mix:
        return Icons.play_arrow_rounded;
      case LearningFocus.vocabulary:
        return Icons.quiz_rounded;
      case LearningFocus.sentences:
        return Icons.translate_rounded;
    }
  }

  Color get _accent {
    switch (widget.focus) {
      case LearningFocus.mix:
        return AppColors.primary;
      case LearningFocus.vocabulary:
        return AppColors.success;
      case LearningFocus.sentences:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? AppMotion.pressScale : 1.0;
    final glow = _pressed ? AppShadows.softGlow(_accent) : const <BoxShadow>[];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: AppRadii.br20,
            border: Border.all(color: AppColors.panelBorder),
            boxShadow: [...AppShadows.panelShadow, ...glow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.16),
                      borderRadius: AppRadii.br16,
                      border: Border.all(color: _accent.withOpacity(0.30)),
                    ),
                    child: Icon(_icon, color: _accent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Continue', style: AppTextStyles.subtitle),
                        const SizedBox(height: 6),
                        Text(_subtitle, style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.s12),

              // Tiny progress bar
              ProgressBar(
                value: widget.progress,
                height: 8,
                color: _accent,
                background: AppColors.panel2,
              ),

              const SizedBox(height: AppSpacing.s12),

              // Tiny focus chip (optional control)
              Align(
                alignment: Alignment.centerLeft,
                child: FocusChip(focus: widget.focus, onTap: widget.onFocusTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
