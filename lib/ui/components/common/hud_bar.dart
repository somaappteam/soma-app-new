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
    required this.onSettingsTap,
    required this.avatarLetter,
    required this.onAvatarTap,
  });

  final String baseLang;
  final String targetLang;
  final int xp;
  final int streak;

  final VoidCallback onCourseTap;
  final VoidCallback onSettingsTap;
  final String avatarLetter;
  final VoidCallback onAvatarTap;

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
          const SizedBox(width: 10),
          _GuestAvatar(letter: avatarLetter, onTap: onAvatarTap),
        ],
      ),
    );
  }
}

class _GuestAvatar extends StatelessWidget {
  const _GuestAvatar({required this.letter, required this.onTap});

  final String letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.panel,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.tooltip,
  });

  final IconData icon;
  final String value;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(value, style: AppTextStyles.numberSmall),
          ],
        ),
      ),
    );
  }
}
