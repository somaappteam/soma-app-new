// lib/ui/components/common/action_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';

/// Reusable action card for Home ("Continue", "Practice", "Compete").
/// It behaves like a Unity menu tile: press bounce + subtle glow.
class ActionCard extends StatefulWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent = AppColors.primary,
    this.big = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
  final bool big;

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? AppMotion.pressScale : 1.0;
    final glow = _pressed
        ? AppShadows.softGlow(widget.accent)
        : const <BoxShadow>[];

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
          padding: EdgeInsets.all(widget.big ? AppSpacing.s20 : AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: AppRadii.br20,
            border: Border.all(color: AppColors.panelBorder),
            boxShadow: [...AppShadows.panelShadow, ...glow],
          ),
          child: Row(
            children: [
              Container(
                width: widget.big ? 52 : 44,
                height: widget.big ? 52 : 44,
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.15),
                  borderRadius: AppRadii.br16,
                  border: Border.all(color: widget.accent.withOpacity(0.25)),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.accent,
                  size: widget.big ? 28 : 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Text(widget.subtitle, style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
