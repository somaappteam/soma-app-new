import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/app_shell.dart';
import '../components/common/panel_card.dart';

class CompetePage extends StatelessWidget {
  const CompetePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Compete Mode',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Multiplayer and matchmaking features are coming soon. Build your streak in the meantime!',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s32),
            PanelCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard_rounded, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Text(
                      'Global Leaderboards',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const Icon(Icons.lock_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            PanelCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_rounded, color: AppColors.success),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Text(
                      'Friend Leagues',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  const Icon(Icons.lock_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
