// lib/ui/components/common/hud_bar.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import 'course_chip.dart';

/// Top HUD bar used across Home/Player/Result.
/// - Left: CourseChip
/// - Right: XP + Streak + Settings
class HudBar extends StatelessWidget {
  const HudBar({
    super.key,
    required this.baseLang,
    required this.targetLang,
    required this.xp,
    required this.streak,
    required this.onCourseTap,
    this.onProfileTap,
  });

  final String baseLang;
  final String targetLang;
  final int xp;
  final int streak;

  final VoidCallback onCourseTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          CourseChip(
            baseLang: baseLang,
            targetLang: targetLang,
            onTap: onCourseTap,
          ),
          const Spacer(),
          _StatPill(
            icon: Icons.star_rounded,
            value: xp.toString(),
            tooltip: 'XP',
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.local_fire_department_rounded,
            value: streak.toString(),
            tooltip: 'Streak',
          ),
          if (onProfileTap != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onProfileTap,
              icon: const Icon(Icons.person_rounded),
              color: AppColors.textPrimary,
              tooltip: 'Profile',
            ),
          ],
        ],
      ),
    );
  }
}


class _StatPill extends StatefulWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    this.tooltip,
  });

  final IconData icon;
  final String value;
  final String? tooltip;

  @override
  State<_StatPill> createState() => _StatPillState();
}

class _StatPillState extends State<_StatPill> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(covariant _StatPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Text(
              widget.value,
              style: AppTextStyles.subtitle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: child);
    }
    return child;
  }
}
