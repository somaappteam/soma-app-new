// lib/ui/components/quiz/vocab_mcq_widget.dart
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/quiz_step_model.dart';
import '../common/panel_card.dart';
import 'answer_button.dart';

typedef SubmitBool = void Function(bool correct);

class VocabMcqWidget extends StatefulWidget {
  const VocabMcqWidget({
    super.key,
    required this.step,
    required this.enabled,
    required this.onSubmit,
    this.showInlineCheck = true,
    this.autoSubmitOnSelect = false,
    this.onCanSubmitChanged,
  });

  final QuizStep step;
  final bool enabled;
  final SubmitBool onSubmit;
  final bool showInlineCheck;
  final bool autoSubmitOnSelect;
  final ValueChanged<bool>? onCanSubmitChanged;

  @override
  State<VocabMcqWidget> createState() => VocabMcqWidgetState();
}

class VocabMcqWidgetState extends State<VocabMcqWidget> {
  int? _selected;
  bool _checked = false;

  bool get canCheck => widget.enabled && _selected != null && !_checked;

  @override
  void initState() {
    super.initState();
    _emitCanSubmit();
  }

  @override
  void didUpdateWidget(covariant VocabMcqWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _selected = null;
      _checked = false;
      _emitCanSubmit();
    }
  }

  void submitSelection() {
    if (!canCheck) return;
    final correctIndex = widget.step.correctIndex ?? -1;
    final correct = _selected == correctIndex;
    setState(() => _checked = true);
    _emitCanSubmit();
    widget.onSubmit(correct);
  }

  void _emitCanSubmit() {
    widget.onCanSubmitChanged?.call(canCheck);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.step.questionWord ?? '';
    final choices = widget.step.choices ?? const <String>[];
    final correctIndex = widget.step.correctIndex ?? -1;

    return AnimatedSwitcher(
      duration: AppMotion.snappy,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation);
        return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
      },
      child: Column(
        key: ValueKey(widget.step.id),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.step.prompt, style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppSpacing.s12),
                Text(word, style: AppTextStyles.title),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ...List.generate(choices.length, (i) {
            final selected = _selected == i;
            AnswerVisualState state = AnswerVisualState.idle;

            if (_checked) {
              if (i == correctIndex) {
                state = AnswerVisualState.correct;
              } else if (selected && i != correctIndex) {
                state = AnswerVisualState.wrong;
              }
            } else {
              state = selected ? AnswerVisualState.selected : AnswerVisualState.idle;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: AnswerButton(
                label: choices[i],
                state: state,
                enabled: widget.enabled && !_checked,
                onTap: () {
                  setState(() => _selected = i);
                  _emitCanSubmit();
                  if (widget.autoSubmitOnSelect) {
                    submitSelection();
                  }
                },
              ),
            );
          }),
          if (widget.showInlineCheck) ...[
            const SizedBox(height: AppSpacing.s8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: canCheck ? submitSelection : null,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Check'),
                style: TextButton.styleFrom(
                  foregroundColor: canCheck ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
