// lib/ui/sheets/vocab_mode_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/vocab_modes/vocab_mode_type.dart';

/// Bottom sheet to pick vocabulary game mode (UI-only).
/// Keep this as the ONLY place to choose modes (no extra pages).
class VocabModePickerSheet extends StatelessWidget {
  const VocabModePickerSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final VocabGameMode current;
  final ValueChanged<VocabGameMode> onSelected;

  static Future<void> show(
    BuildContext context, {
    required VocabGameMode current,
    required ValueChanged<VocabGameMode> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) =>
          VocabModePickerSheet(current: current, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modes = VocabGameMode.values;

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
                Text('Vocabulary Mode', style: AppTextStyles.subtitle),
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
              'Choose how vocabulary plays. You can change anytime.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s16),

            ...modes.map((m) {
              final selected = m == current;
              return _ModeRow(
                title: m.title,
                subtitle: m.subtitle,
                selected: selected,
                badge: m.isCompetitiveDefault ? 'Default for Compete' : null,
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
    this.badge,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

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
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.body),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
