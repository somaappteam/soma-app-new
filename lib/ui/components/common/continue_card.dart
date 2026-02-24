import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'progress_bar.dart';

class ContinueCard extends StatefulWidget {
  const ContinueCard({
    super.key,
    required this.onTap,
    required this.progress,
    required this.etaText,
  });

  final VoidCallback onTap;
  final double progress;
  final String etaText;

  @override
  State<ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<ContinueCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? AppMotion.pressScale : 1.0;
    final glow = _pressed ? AppShadows.softGlow(AppColors.success) : const <BoxShadow>[];

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
                      color: AppColors.success.withOpacity(0.16),
                      borderRadius: AppRadii.br16,
                      border: Border.all(color: AppColors.success.withOpacity(0.30)),
                    ),
                    child: const Icon(Icons.quiz_rounded, color: AppColors.success, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Continue', style: AppTextStyles.subtitle),
                        const SizedBox(height: 6),
                        Text('Next: Vocabulary • ${widget.etaText}', style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              ProgressBar(
                value: widget.progress,
                height: 8,
                color: AppColors.success,
                background: AppColors.panel2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
