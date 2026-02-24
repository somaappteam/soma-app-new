import 'package:flutter/material.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../screens/player_page.dart';
import '../vocab_modes/vocab_mode_type.dart';

class GameModeGrid extends StatelessWidget {
  const GameModeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vocabulary Mini Games', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.s4),
        Text('Master vocabulary in bite-sized chunks.', style: AppTextStyles.bodyMuted),
        const SizedBox(height: AppSpacing.s16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.s12,
          crossAxisSpacing: AppSpacing.s12,
          childAspectRatio: 1.1,
          children: [
            _GameCard(
              title: 'Rapid Chain',
              subtitle: 'Quick vocab recall',
              iconText: '⚡',
              color: AppColors.accent,
              onTap: () => _launch(context, VocabGameMode.rapidChain),
            ),
            _GameCard(
              title: 'Survival',
              subtitle: 'Beat the clock',
              iconText: '⏱️',
              color: Colors.redAccent,
              onTap: () => _launch(context, VocabGameMode.survivalTimer),
            ),
            _GameCard(
              title: 'Falling Words',
              subtitle: 'Catch the blocks',
              iconText: '🌧️',
              color: Colors.blueAccent,
              onTap: () => _launch(context, VocabGameMode.fallingWords),
            ),
          ],
        ),
      ],
    );
  }

  void _launch(BuildContext context, VocabGameMode mode) {
    Navigator.pushNamed(
      context,
      AppRouter.player,
      arguments: PlayerArgs.solo(isPractice: true, vocabMode: mode),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.iconText,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconText;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(iconText, style: const TextStyle(fontSize: 24)),
            ),
            const Spacer(),
            Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
