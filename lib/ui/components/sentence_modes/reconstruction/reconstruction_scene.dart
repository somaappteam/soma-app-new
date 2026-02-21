// lib/ui/components/sentence_modes/reconstruction/reconstruction_scene.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/spacing.dart';
import '../../common/panel_card.dart';
import 'reconstruction_hud.dart';

/// Sentence Reconstruction (Countdown Mode)
///
/// Inputs:
/// - nativeSentence: shown at top (what user understands)
/// - targetTokensCorrect: correct token sequence (what user must build)
/// - distractorToken: 1 extra wrong token
///
/// Mechanics:
/// - show shuffled token bank = correct tokens + distractor
/// - user taps tokens to add to "built" row
/// - user can reorder built tokens (drag)
/// - countdown timer ends run at 0
///
/// Outputs:
/// - onAnswered(correct)
/// - onTimeout()
class ReconstructionScene extends StatefulWidget {
  const ReconstructionScene({
    super.key,
    required this.nativeSentence,
    required this.targetTokensCorrect,
    required this.distractorToken,
    required this.seconds,
    required this.enabled,
    required this.onAnswered,
    required this.onTimeout,
  });

  final String nativeSentence;
  final List<String> targetTokensCorrect;
  final String distractorToken;
  final int seconds;

  final bool enabled;

  final void Function(bool correct) onAnswered;
  final VoidCallback onTimeout;

  @override
  State<ReconstructionScene> createState() => _ReconstructionSceneState();
}

class _ReconstructionSceneState extends State<ReconstructionScene> {
  late List<String> bank;
  final List<String> built = [];

  Timer? _timer;
  late int _msLeft;

  bool checked = false;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant ReconstructionScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nativeSentence != widget.nativeSentence) {
      _reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset() {
    _timer?.cancel();

    built.clear();
    checked = false;
    isCorrect = null;

    bank = [...widget.targetTokensCorrect, widget.distractorToken];
    bank.shuffle(Random());

    _msLeft = widget.seconds * 1000;

    if (widget.enabled) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) return;
        if (checked) return;
        setState(() => _msLeft -= 100);
        if (_msLeft <= 0) {
          _msLeft = 0;
          t.cancel();
          widget.onTimeout();
        }
      });
    }
    setState(() {});
  }

  void _toggleFromBank(String token) {
    if (!widget.enabled || checked) return;

    setState(() {
      if (built.contains(token)) {
        built.remove(token);
      } else {
        built.add(token);
      }
    });
  }

  void _removeFromBuilt(String token) {
    if (!widget.enabled || checked) return;
    setState(() => built.remove(token));
  }

  bool _validate() {
    // Must match exact sequence and length
    if (built.length != widget.targetTokensCorrect.length) return false;
    for (int i = 0; i < built.length; i++) {
      if (built[i] != widget.targetTokensCorrect[i]) return false;
    }
    return true;
  }

  void _check() {
    if (!widget.enabled || checked) return;
    setState(() {
      checked = true;
      isCorrect = _validate();
    });
    widget.onAnswered(isCorrect == true);
  }

  double get _timeLeftSeconds => _msLeft / 1000.0;
  int get _placed => built.length;
  int get _total => widget.targetTokensCorrect.length;

  @override
  Widget build(BuildContext context) {
    final timeText = (_msLeft / 1000).toStringAsFixed(1);
    final timeColor = _msLeft <= 5000
        ? AppColors.danger
        : (_msLeft <= 10000 ? AppColors.warning : AppColors.success);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header card: native sentence + timer
        PanelCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Translate & reconstruct', style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.s8),
              Text(
                widget.nativeSentence,
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
                  if (checked && isCorrect != null)
                    _ResultPill(correct: isCorrect!),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s12),
        ReconstructionHud(
          timeLeftSeconds: _timeLeftSeconds,
          placed: _placed,
          total: _total,
          showDistractorHint: true,
        ),
        const SizedBox(height: AppSpacing.s16),

        // Built (reorderable)
        PanelCard(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your sentence', style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.s8),

              if (built.isEmpty)
                Text(
                  'Tap words below to build the sentence.',
                  style: AppTextStyles.bodyMuted,
                )
              else
                ReorderableWrap(
                  items: built,
                  enabled: widget.enabled && !checked,
                  onRemove: _removeFromBuilt,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final item = built.removeAt(oldIndex);
                      built.insert(newIndex, item);
                    });
                  },
                  checked: checked,
                  correctTokens: widget.targetTokensCorrect,
                  isCorrect: isCorrect,
                ),

              const SizedBox(height: AppSpacing.s12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed:
                      (!checked &&
                          built.isNotEmpty &&
                          widget.enabled &&
                          _msLeft > 0)
                      ? _check
                      : null,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Check'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        (!checked &&
                            built.isNotEmpty &&
                            widget.enabled &&
                            _msLeft > 0)
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        // Token bank
        PanelCard(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Word blocks', style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s12,
                children: bank.map((t) {
                  final selected = built.contains(t);
                  return _TokenChip(
                    token: t,
                    selected: selected,
                    enabled: widget.enabled && !checked,
                    checked: checked,
                    // after check: mark correct tokens lightly, distractor stays normal
                    correctTokenSet: widget.targetTokensCorrect.toSet(),
                    isDistractor: t == widget.distractorToken,
                    onTap: () => _toggleFromBank(t),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.correct});
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.danger;
    final text = correct ? 'Correct' : 'Wrong';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    required this.selected,
    required this.enabled,
    required this.checked,
    required this.correctTokenSet,
    required this.isDistractor,
    required this.onTap,
  });

  final String token;
  final bool selected;
  final bool enabled;
  final bool checked;
  final Set<String> correctTokenSet;
  final bool isDistractor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.panelBorder;
    Color bg = AppColors.panel2;

    if (!checked) {
      if (selected) {
        border = AppColors.primary.withOpacity(0.55);
        bg = AppColors.primary.withOpacity(0.16);
      }
    } else {
      // after check, lightly mark correct tokens (even in bank)
      if (correctTokenSet.contains(token)) {
        border = AppColors.success.withOpacity(0.40);
        bg = AppColors.success.withOpacity(0.10);
      }
      // distractor stays neutral
      if (isDistractor) {
        border = AppColors.panelBorder;
        bg = AppColors.panel2;
      }
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          token,
          style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Simple reorderable wrap using ReorderableListView feel but in wrap layout.
class ReorderableWrap extends StatelessWidget {
  const ReorderableWrap({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onRemove,
    required this.enabled,
    required this.checked,
    required this.correctTokens,
    required this.isCorrect,
  });

  final List<String> items;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String token) onRemove;
  final bool enabled;

  final bool checked;
  final List<String> correctTokens;
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    // We'll implement a lightweight reorder with ReorderableListView (vertical),
    // but visually present as tokens. It’s robust and simple.
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        if (!enabled) return;
        if (newIndex > oldIndex) newIndex -= 1;
        onReorder(oldIndex, newIndex);
      },
      children: [
        for (int i = 0; i < items.length; i++)
          ListTile(
            key: ValueKey('built_${i}_${items[i]}'),
            contentPadding: EdgeInsets.zero,
            title: _BuiltToken(
              token: items[i],
              enabled: enabled,
              onRemove: () => onRemove(items[i]),
              checked: checked,
              index: i,
              correctTokens: correctTokens,
              isCorrect: isCorrect,
            ),
            trailing: enabled
                ? const Icon(
                    Icons.drag_handle_rounded,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
      ],
    );
  }
}

class _BuiltToken extends StatelessWidget {
  const _BuiltToken({
    required this.token,
    required this.enabled,
    required this.onRemove,
    required this.checked,
    required this.index,
    required this.correctTokens,
    required this.isCorrect,
  });

  final String token;
  final bool enabled;
  final VoidCallback onRemove;

  final bool checked;
  final int index;
  final List<String> correctTokens;
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.panelBorder;
    Color bg = AppColors.panel2;

    if (checked && isCorrect != null) {
      if (index < correctTokens.length && token == correctTokens[index]) {
        border = AppColors.success.withOpacity(0.65);
        bg = AppColors.success.withOpacity(0.14);
      } else {
        border = AppColors.danger.withOpacity(0.65);
        bg = AppColors.danger.withOpacity(0.14);
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border),
            ),
            child: Text(
              token,
              style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (enabled)
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
