// lib/ui/components/quiz/vocab_mcq_widget.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../../../models/quiz_step_model.dart';
import '../common/panel_card.dart';
import 'answer_button.dart';

typedef SubmitBool = void Function(bool correct);

/// Vocabulary multiple-choice widget.
/// UI-only: it handles local selection and checks correctness.
class VocabMcqWidget extends StatefulWidget {
  const VocabMcqWidget({
    super.key,
    required this.step,
    required this.enabled,
    required this.onSubmit,
  });

  final QuizStep step;
  final bool enabled;
  final SubmitBool onSubmit;

  @override
  State<VocabMcqWidget> createState() => _VocabMcqWidgetState();
}

class _VocabMcqWidgetState extends State<VocabMcqWidget> {
  int? _selected;
  bool _checked = false;

  @override
  void didUpdateWidget(covariant VocabMcqWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _selected = null;
      _checked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.step.questionWord ?? '';
    final choices = widget.step.choices ?? const <String>[];
    final correctIndex = widget.step.correctIndex ?? -1;

    return Column(
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
            } else {
              state = AnswerVisualState.idle;
            }
          } else {
            state = selected
                ? AnswerVisualState.selected
                : AnswerVisualState.idle;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: AnswerButton(
              label: choices[i],
              state: state,
              enabled: widget.enabled && !_checked,
              onTap: () => setState(() => _selected = i),
            ),
          );
        }),

        const SizedBox(height: AppSpacing.s8),

        // Inline "Check" for MCQ.
        // PlayerPage also has a global CTA; keeping this subtle helps UX.
        _InlineCheck(
          enabled: widget.enabled && _selected != null && !_checked,
          onTap: () {
            if (_selected == null) return;
            setState(() => _checked = true);
            final correct = _selected == correctIndex;
            widget.onSubmit(correct);
          },
        ),
      ],
    );
  }
}

class _InlineCheck extends StatelessWidget {
  const _InlineCheck({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: enabled ? onTap : null,
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text('Check'),
        style: TextButton.styleFrom(
          foregroundColor: enabled ? AppColors.success : AppColors.textMuted,
        ),
      ),
    );
  }
}
