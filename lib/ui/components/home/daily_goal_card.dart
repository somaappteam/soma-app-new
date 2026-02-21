import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../common/panel_card.dart';

class DailyGoalCard extends StatelessWidget {
  final int currentXp;
  final int dailyGoal;
  final int streak;

  const DailyGoalCard({
    super.key,
    required this.currentXp,
    this.dailyGoal = 50,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / dailyGoal).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PanelCard(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return CircularProgressIndicator(
                            value: val,
                            backgroundColor: AppColors.panelBorder,
                            color: AppColors.accent,
                            strokeWidth: 5,
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                      const Center(
                        child: Icon(Icons.bolt_rounded, color: AppColors.accent, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Goal', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('$currentXp / $dailyGoal XP', style: AppTextStyles.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        // Streak Card
        Expanded(
          flex: 4,
          child: PanelCard(
             padding: const EdgeInsets.all(AppSpacing.s12),
             child: Row(
               children: [
                 Container(
                   width: 44,
                   height: 44,
                   decoration: BoxDecoration(
                     color: Colors.orange.withOpacity(0.15),
                     shape: BoxShape.circle,
                   ),
                   child: const Center(
                     child: Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
                   ),
                 ),
                 const SizedBox(width: AppSpacing.s12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Streak', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                       const SizedBox(height: 4),
                       Text('$streak days', style: AppTextStyles.small),
                     ],
                   ),
                 ),
               ],
             ),
          ),
        ),
      ],
    );
  }
}
