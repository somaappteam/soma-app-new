// lib/ui/components/sentence_modes/speed_elimination/speed_elimination_scene.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';
import '../../quiz/answer_button.dart';
import 'speed_elimination_hud.dart';

/// Speed Elimination (Sentence Mode)
///
/// Inputs:
/// - targetSentence: shown to user (target language)
/// - optionsNative: 4 translations (native language)
/// - correctIndex: correct option index
/// - seconds: overall time limit
///
/// Mechanics:
/// - timer runs
/// - wrong options disappear automatically over time
/// - user must pick correct before it's eliminated / time out
///
/// Outputs:
/// - onAnswered(correct)
/// - onTimeout()
class SpeedEliminationScene extends StatefulWidget {
  const SpeedEliminationScene({
    super.key,
    required this.targetSentence,
    required this.optionsNative,
    required this.correctIndex,
    required this.seconds,
    required this.enabled,
    required this.onAnswered,
    required this.onTimeout,
  });

  final String targetSentence;
  final List<String> optionsNative;
  final int correctIndex;
  final int seconds;

  final bool enabled;

  final void Function(bool correct) onAnswered;
  final VoidCallback onTimeout;

  @override
  State<SpeedEliminationScene> createState() => _SpeedEliminationSceneState();
}

class _SpeedEliminationSceneState extends State<SpeedEliminationScene> {
  late int _msLeft;
  Timer? _timer;

  bool checked = false;
  int? selectedIndex;

  // Which indices are still visible
  late List<int> alive;

  // schedule elimination ticks (indices removed over time)
  Timer? _elimTimer;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant SpeedEliminationScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetSentence != widget.targetSentence) {
      _reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elimTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _timer?.cancel();
    _elimTimer?.cancel();

    checked = false;
    selectedIndex = null;

    alive = List<int>.generate(widget.optionsNative.length, (i) => i);

    _msLeft = widget.seconds * 1000;

    if (widget.enabled) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) return;
        if (checked) return;
        setState(() => _msLeft -= 100);
        if (_msLeft <= 0) {
          _msLeft = 0;
          t.cancel();
          _elimTimer?.cancel();
          widget.onTimeout();
        }
      });

      // eliminate wrong answers gradually:
      // every 1.1s remove one random WRONG alive option (never remove correct)
      _elimTimer = Timer.periodic(const Duration(milliseconds: 1100), (t) {
        if (!mounted) return;
        if (checked) return;

        // stop when only correct remains or only 2 remain
        if (alive.length <= 2) return;

        final candidates = alive
            .where((i) => i != widget.correctIndex)
            .toList();
        if (candidates.isEmpty) return;

        final removeIdx = candidates[_rng.nextInt(candidates.length)];
        setState(() {
          alive.remove(removeIdx);

          // if user had selected removed option, clear selection
          if (selectedIndex == removeIdx) selectedIndex = null;
        });
      });
    }
    setState(() {});
  }

  void _select(int i) {
    if (!widget.enabled || checked) return;
    if (!alive.contains(i)) return;
    setState(() => selectedIndex = i);
  }

  void _submit(int i) {
    if (!widget.enabled || checked) return;
    if (!alive.contains(i)) return;

    final correct = i == widget.correctIndex;
    setState(() {
      checked = true;
      selectedIndex = i;
    });

    _timer?.cancel();
    _elimTimer?.cancel();

    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    final timeText = (_msLeft / 1000).toStringAsFixed(1);
    final timeColor = _msLeft <= 4000
        ? AppColors.danger
        : (_msLeft <= 8000 ? AppColors.warning : AppColors.success);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Speed Elimination', style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.s8),
              Text(
                widget.targetSentence,
                style: AppTextStyles.subtitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Icon(Icons.timer_rounded, color: timeColor),
                  const SizedBox(width: 8),
                  Text(
                    '$timeText s',
                    style: AppTextStyles.subtitle.copyWith(color: timeColor),
                  ),
                  const Spacer(),
                  Text('Wrong options disappear…', style: AppTextStyles.small),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        SpeedEliminationHud(
          timeLeftSeconds: _msLeft / 1000.0,
          optionsLeft: alive.length,
        ),
        const SizedBox(height: AppSpacing.s16),

        ...List.generate(widget.optionsNative.length, (i) {
          final visible = alive.contains(i);

          final selected = selectedIndex == i;

          AnswerVisualState state = AnswerVisualState.idle;
          if (!checked) {
            state = selected
                ? AnswerVisualState.selected
                : AnswerVisualState.idle;
          } else {
            if (i == widget.correctIndex) {
              state = AnswerVisualState.correct;
            } else if (selected && i != widget.correctIndex) {
              state = AnswerVisualState.wrong;
            } else {
              state = AnswerVisualState.idle;
            }
          }

          return AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: AnimatedScale(
                scale: visible ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: visible
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: AnswerButton(
                          label: widget.optionsNative[i],
                          state: state,
                          enabled: widget.enabled && !checked,
                          onTap: () => _submit(i),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        }),
      ],
    );
  }
}
