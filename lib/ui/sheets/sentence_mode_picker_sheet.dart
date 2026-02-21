// lib/ui/sheets/sentence_mode_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/sentence_modes/sentence_mode_type.dart';

/// Bottom sheet to pick sentence game mode (UI-only).
class SentenceModePickerSheet extends StatelessWidget {
  const SentenceModePickerSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final SentenceGameMode current;
  final ValueChanged<SentenceGameMode> onSelected;

  static Future<void> show(
    BuildContext context, {
    required SentenceGameMode current,
    required ValueChanged<SentenceGameMode> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) =>
          SentenceModePickerSheet(current: current, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modes = SentenceGameMode.values;

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
                Text('Sentence Mode', style: AppTextStyles.subtitle),
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
              'Choose how sentence questions play.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s16),

            ...modes.map((m) {
              final selected = m == current;
              return _ModeRow(
                title: m.title,
                subtitle: m.subtitle,
                selected: selected,
                onTap: () {
                  onSelected(m);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
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
    final border = selected
        ? AppColors.primary.withOpacity(0.55)
        : AppColors.panelBorder;

    final bg = selected
        ? AppColors.primary.withOpacity(0.12)
        : AppColors.panel2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textMuted,
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
