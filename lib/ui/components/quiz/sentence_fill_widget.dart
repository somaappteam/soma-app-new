// lib/ui/components/quiz/sentence_fill_widget.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../../../models/quiz_step_model.dart';
import '../common/panel_card.dart';

typedef SubmitBool = void Function(bool correct);

/// Sentence fill-in (word bank) widget.
/// Keeps UX simple and avoids spelling issues. Great for "Unity-feel" interactions.
class SentenceFillWidget extends StatefulWidget {
  const SentenceFillWidget({
    super.key,
    required this.step,
    required this.enabled,
    required this.onSubmit,
  });

  final QuizStep step;
  final bool enabled;
  final SubmitBool onSubmit;

  @override
  State<SentenceFillWidget> createState() => _SentenceFillWidgetState();
}

class _SentenceFillWidgetState extends State<SentenceFillWidget> {
  String? _picked;
  bool _checked = false;

  @override
  void didUpdateWidget(covariant SentenceFillWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _picked = null;
      _checked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.step.sentenceWithBlank ?? '';
    final bank = widget.step.wordBank ?? const <String>[];
    final correctWord = widget.step.correctWord ?? '';

    final displaySentence = sentence.replaceAll('___', _picked ?? '____');

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
              Text(
                displaySentence,
                style: AppTextStyles.subtitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text('Tap a word to fill the blank', style: AppTextStyles.small),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        Wrap(
          spacing: AppSpacing.s12,
          runSpacing: AppSpacing.s12,
          children: bank.map((w) {
            final selected = _picked == w;
            return _WordChip(
              word: w,
              selected: selected,
              enabled: widget.enabled,
              checked: _checked,
              correctWord: correctWord,
              pickedWord: _picked,
              onTap: () => setState(() => _picked = selected ? null : w),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.s16),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: (widget.enabled && _picked != null && !_checked)
                ? () {
                    setState(() => _checked = true);
                    final correct = (_picked == correctWord);
                    widget.onSubmit(correct);
                  }
                : null,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Check'),
            style: TextButton.styleFrom(
              foregroundColor: (widget.enabled && _picked != null)
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.selected,
    required this.enabled,
    required this.checked,
    required this.correctWord,
    required this.pickedWord,
    required this.onTap,
  });

  final String word;
  final bool selected;
  final bool enabled;

  final bool checked;
  final String correctWord;
  final String? pickedWord;

  final VoidCallback onTap;

  bool get _isCorrect => word == correctWord;
  bool get _isPickedWrong => checked && pickedWord == word && !_isCorrect;

  Color get _border {
    if (!checked) {
      return selected
          ? AppColors.secondary.withOpacity(0.45)
          : AppColors.panelBorder;
    }
    if (_isCorrect) return AppColors.success.withOpacity(0.65);
    if (_isPickedWrong) return AppColors.danger.withOpacity(0.65);
    return AppColors.panelBorder;
  }

  Color get _bg {
    if (!checked) {
      return selected ? AppColors.secondary.withOpacity(0.18) : AppColors.panel;
    }
    if (_isCorrect) return AppColors.success.withOpacity(0.14);
    if (_isPickedWrong) return AppColors.danger.withOpacity(0.14);
    return AppColors.panel;
  }

  IconData? get _icon {
    if (!checked) return null;
    if (_isCorrect) return Icons.check_circle_rounded;
    if (_isPickedWrong) return Icons.cancel_rounded;
    return null;
  }

  Color get _iconColor {
    if (_isCorrect) return AppColors.success;
    if (_isPickedWrong) return AppColors.danger;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (enabled && !checked) ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: selected
                  ? AppTextStyles.body
                  : AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.textPrimary,
                    ),
            ),
            if (_icon != null) ...[
              const SizedBox(width: 8),
              Icon(_icon, size: 18, color: _iconColor),
            ],
          ],
        ),
      ),
    );
  }
}
