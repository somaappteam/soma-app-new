import 'package:flutter/material.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../screens/player_page.dart';
import '../sentence_modes/sentence_mode_type.dart';
import '../vocab_modes/vocab_mode_type.dart';

class GameModeGrid extends StatelessWidget {
  const GameModeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mini Games', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.s4),
        Text('Master vocabulary and grammar in bite-sized chunks.', style: AppTextStyles.bodyMuted),
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
              onTap: () => _launchVocab(context, VocabGameMode.rapidChain),
            ),
            _GameCard(
              title: 'Survival',
              subtitle: 'Beat the clock',
              iconText: '⏱️',
              color: Colors.redAccent,
              onTap: () => _launchVocab(context, VocabGameMode.survivalTimer),
            ),
            _GameCard(
              title: 'Falling Words',
              subtitle: 'Catch the blocks',
              iconText: '🌧️',
              color: Colors.blueAccent,
              onTap: () => _launchVocab(context, VocabGameMode.fallingWords),
            ),
            _GameCard(
              title: 'Reconstruct',
              subtitle: 'Sentence puzzles',
              iconText: '🧩',
              color: AppColors.success,
              onTap: () => _launchSentence(context, SentenceGameMode.reconstructionCountdown),
            ),
            _GameCard(
              title: 'Speed Elim',
              subtitle: 'Spot the errors',
              iconText: '🎯',
              color: Colors.orangeAccent,
              onTap: () => _launchSentence(context, SentenceGameMode.speedElimination),
            ),
          ],
        ),
      ],
    );
  }

  void _launchVocab(BuildContext context, VocabGameMode mode) {
    Navigator.pushNamed(
      context,
      AppRouter.player,
      arguments: PlayerArgs.solo(
        isPractice: true,
        vocabMode: mode,
        sentenceMode: SentenceGameMode.reconstructionCountdown,
      ),
    );
  }

  void _launchSentence(BuildContext context, SentenceGameMode mode) {
    Navigator.pushNamed(
      context,
      AppRouter.player,
      arguments: PlayerArgs.solo(
        isPractice: true,
        vocabMode: VocabGameMode.rapidChain,
        sentenceMode: mode,
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconText;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.iconText,
    required this.color,
    required this.onTap,
  });

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
          boxShadow: [
             BoxShadow(
               color: color.withValues(alpha: 0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
