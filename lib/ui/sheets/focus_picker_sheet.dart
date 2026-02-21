// lib/ui/sheets/focus_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/common/focus_chip.dart'; // LearningFocus enum lives here

/// Small bottom sheet to pick learning focus:
/// Mix (recommended) / Vocabulary / Sentences
class FocusPickerSheet extends StatelessWidget {
  const FocusPickerSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final LearningFocus current;
  final ValueChanged<LearningFocus> onSelected;

  static Future<void> show(
    BuildContext context, {
    required LearningFocus current,
    required ValueChanged<LearningFocus> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) =>
          FocusPickerSheet(current: current, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: PanelCard(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Learning Focus', style: AppTextStyles.subtitle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Choose what Continue/Practice/Compete will use.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s16),

            _RadioRow(
              title: 'Mix',
              subtitle: 'Vocabulary + Sentences (recommended)',
              selected: current == LearningFocus.mix,
              onTap: () {
                onSelected(LearningFocus.mix);
                Navigator.pop(context);
              },
            ),
            _RadioRow(
              title: 'Vocabulary',
              subtitle: 'Multiple choice words only',
              selected: current == LearningFocus.vocabulary,
              onTap: () {
                onSelected(LearningFocus.vocabulary);
                Navigator.pop(context);
              },
            ),
            _RadioRow(
              title: 'Sentences',
              subtitle: 'Fill in the blank only',
              selected: current == LearningFocus.sentences,
              onTap: () {
                onSelected(LearningFocus.sentences);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
