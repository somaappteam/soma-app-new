// lib/ui/screens/result_page.dart
import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/animated_counter.dart';
import '../components/common/app_shell.dart';
import '../components/common/app_toast.dart';
import '../components/common/fire_pulse.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';
import 'player_page.dart';

/// Route args for ResultPage (used by AppRouter).
class ResultArgs {
  ResultArgs({
    required this.mode,
    required this.xpGained,
    required this.accuracy,
    this.youWon,
    this.survivalSeconds,
    this.bestStreak,
  });

  final SessionMode mode;
  final int xpGained;
  final double accuracy; // 0..1
  final bool? youWon;
  final double? survivalSeconds;
  final int? bestStreak;

  factory ResultArgs.empty() => ResultArgs(
    mode: SessionMode.solo,
    xpGained: 0,
    accuracy: 0,
    youWon: null,
    survivalSeconds: null,
    bestStreak: null,
  );
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.args});

  final ResultArgs args;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;

    // micro celebration toast (streak saved)
    Future.microtask(() {
      if (!mounted) return;
      AppToast.showSuccess(context, 'Streak +1 🔥');
    });
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.args.accuracy * 100).round();
    final isCompete = widget.args.mode == SessionMode.compete;

    return AppShell(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s16),
            PanelCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompete) ...[
                    _WinLoseBanner(youWon: widget.args.youWon ?? false),
                    const SizedBox(height: AppSpacing.s12),
                  ],
                  Text('Results', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('XP earned', style: AppTextStyles.body),
                      ),
                      AnimatedCounter(
                        from: 0,
                        to: widget.args.xpGained,
                        prefix: '+',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _StatRow(
                    icon: Icons.check_circle_rounded,
                    label: 'Accuracy',
                    value: '$pct%',
                    valueColor: AppColors.success,
                  ),
                  if (widget.args.survivalSeconds != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    _StatRow(
                      icon: Icons.timer_rounded,
                      label: 'Survival time',
                      value:
                          '${widget.args.survivalSeconds!.toStringAsFixed(1)}s',
                      valueColor: AppColors.success,
                    ),
                  ],
                  if (widget.args.bestStreak != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    _StatRow(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Best streak',
                      value: '${widget.args.bestStreak}',
                      valueColor: AppColors.secondary,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      const FirePulse(size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Streak', style: AppTextStyles.body),
                      ),
                      Text(
                        '+1 day',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    isCompete
                        ? 'Great duel! Want a rematch?'
                        : 'Nice work — keep the streak going.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),

            const Spacer(),

            if (isCompete) ...[
              PrimaryButton(
                label: 'Rematch',
                onTap: () {
                  // UI-only: just go back to PlayerPage compete.
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.player,
                    arguments: const PlayerArgs.compete(),
                  );
                },
                color: AppColors.secondary,
                pressedColor: AppColors.secondaryPressed,
                icon: Icons.refresh_rounded,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],

            PrimaryButton(
              label: 'Continue',
              onTap: () {
                // For simplicity: go Home.
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.home,
                  (_) => false,
                );
              },
              icon: Icons.home_rounded,
            ),
            const SizedBox(height: AppSpacing.s12),

            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.home,
                (_) => false,
              ),
              child: const Text('Home'),
            ),

            const SizedBox(height: AppSpacing.s16),
          ],
        ),
      ),
    );
  }
}

class _WinLoseBanner extends StatelessWidget {
  const _WinLoseBanner({required this.youWon});

  final bool youWon;

  @override
  Widget build(BuildContext context) {
    final title = youWon ? 'YOU WIN 🏆' : 'GOOD TRY 💪';
    final color = youWon ? AppColors.success : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(value, style: AppTextStyles.subtitle.copyWith(color: valueColor)),
      ],
    );
  }
}
