// lib/ui/components/vocab_modes/falling_words/falling_words_scene.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';
import '../../quiz/answer_button.dart';
import '../../../../models/quiz_step_model.dart';
import '../falling_words_controller.dart';

/// Falling Words (Visual Pressure Mode) - UI-only scene.
/// - Word card falls from top -> bottom.
/// - User answers with 4 buttons at bottom.
/// - If reaches bottom: onFailed() is called.
/// - After answer: onAnswered(correct) is called.
///
/// PlayerPage can wrap this scene for session flow.
/// This scene is designed to be self-contained and reusable.
class FallingWordsScene extends StatefulWidget {
  const FallingWordsScene({
    super.key,
    required this.step,
    required this.enabled,
    required this.onAnswered,
    required this.onFailed,
    required this.controller,
    this.initialDurationMs = 4200,
  });

  final QuizStep step; // must be vocabMcq
  final bool enabled;
  final void Function(bool correct) onAnswered;
  final VoidCallback onFailed;
  final FallingWordsController controller;

  /// Base fall duration; will speed up as streak increases (inside this widget).
  final int initialDurationMs;

  @override
  State<FallingWordsScene> createState() => _FallingWordsSceneState();
}

class _FallingWordsSceneState extends State<FallingWordsScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _fallCtrl;

  bool checked = false;
  int? selectedIndex;

  bool frozen = false;

  Timer? _freezeTimer;

  @override
  void initState() {
    super.initState();
    _fallCtrl =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.initialDurationMs),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            // Word hit the bottom -> fail
            if (!checked) widget.onFailed();
          }
        });

    _startFall();
  }

  @override
  void didUpdateWidget(covariant FallingWordsScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      // new question -> reset state and restart fall
      checked = false;
      selectedIndex = null;
      _startFall();
    }
  }

  @override
  void dispose() {
    _freezeTimer?.cancel();
    _fallCtrl.dispose();
    super.dispose();
  }

  void _startFall() {
    _fallCtrl.stop();
    _fallCtrl.value = 0;

    // use controller-based duration (speeds up as streak grows)
    final dur = widget.controller.fallDurationMs;
    _fallCtrl.duration = Duration(milliseconds: dur);

    if (widget.enabled) _fallCtrl.forward(from: 0);
  }

  void _freezeOnce() {
    if (!widget.controller.canUseFreeze() || frozen || checked) return;
    widget.controller.useFreeze();
    frozen = true;
    _fallCtrl.stop();

    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      frozen = false;
      if (!checked && widget.enabled) {
        _fallCtrl.forward();
      }
      setState(() {});
    });

    setState(() {});
  }

  void _select(int i) {
    if (!widget.enabled || checked) return;
    setState(() => selectedIndex = i);
  }

  void _submit() {
    if (!widget.enabled || checked) return;
    if (selectedIndex == null) return;

    final correctIndex = widget.step.correctIndex ?? -1;
    final correct = selectedIndex == correctIndex;

    setState(() => checked = true);

    _fallCtrl.stop();

    // Update controller streak (pressure)
    if (correct) {
      widget.controller.markCorrect();
    } else {
      widget.controller.markWrong();
    }

    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.step.questionWord ?? '';
    final choices = widget.step.choices ?? const <String>[];
    final correctIndex = widget.step.correctIndex ?? -1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final topY = 0.0;
        final bottomY = height * 0.62; // landing zone above answers

        return Stack(
          children: [
            // Falling card
            AnimatedBuilder(
              animation: _fallCtrl,
              builder: (context, _) {
                final y = topY + (bottomY - topY) * _fallCtrl.value;
                return Positioned(
                  top: y,
                  left: AppSpacing.s16,
                  right: AppSpacing.s16,
                  child: PanelCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Falling Words', style: AppTextStyles.small),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.panel2,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.panelBorder,
                                ),
                              ),
                              child: Text(
                                'Streak ${widget.controller.streak}',
                                style: AppTextStyles.small,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(word, style: AppTextStyles.title),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Answer before it hits bottom!',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Freeze button
            Positioned(
              top: AppSpacing.s16,
              right: AppSpacing.s16,
              child: TextButton.icon(
                onPressed: (widget.controller.freezeUsed || checked)
                    ? null
                    : _freezeOnce,
                icon: Icon(
                  Icons.ac_unit_rounded,
                  color: widget.controller.freezeUsed
                      ? AppColors.textMuted
                      : AppColors.primary,
                ),
                label: Text(
                  widget.controller.freezeUsed
                      ? 'Freeze used'
                      : (frozen ? 'Frozen' : 'Freeze'),
                  style: AppTextStyles.small.copyWith(
                    color: widget.controller.freezeUsed
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Answer area anchored bottom
            Positioned(
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              bottom: AppSpacing.s12,
              child: Column(
                children: [
                  // Optional check button (keeps UX explicit)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pick the answer',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: (!checked && selectedIndex != null)
                            ? _submit
                            : null,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Check'),
                        style: TextButton.styleFrom(
                          foregroundColor: (!checked && selectedIndex != null)
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  ...List.generate(choices.length, (i) {
                    final selected = selectedIndex == i;

                    AnswerVisualState state = AnswerVisualState.idle;
                    if (!checked) {
                      state = selected
                          ? AnswerVisualState.selected
                          : AnswerVisualState.idle;
                    } else {
                      if (i == correctIndex) {
                        state = AnswerVisualState.correct;
                      } else if (selected && i != correctIndex) {
                        state = AnswerVisualState.wrong;
                      } else {
                        state = AnswerVisualState.idle;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: AnswerButton(
                        label: choices[i],
                        state: state,
                        enabled: widget.enabled && !checked,
                        onTap: () => _select(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
