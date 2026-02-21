// lib/ui/sheets/settings_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';

/// UI-only Settings sheet. Later wire to AppController settings.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.soundOn,
    required this.hapticsOn,
    required this.onSoundChanged,
    required this.onHapticsChanged,
    required this.onAccountTap,
    required this.accountLabel,
    required this.avatarLetter,
  });

  final bool soundOn;
  final bool hapticsOn;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onAccountTap;
  final String accountLabel;
  final String avatarLetter;

  static Future<void> show(
    BuildContext context, {
    required bool soundOn,
    required bool hapticsOn,
    required ValueChanged<bool> onSoundChanged,
    required ValueChanged<bool> onHapticsChanged,
    required VoidCallback onAccountTap,
    required String accountLabel,
    required String avatarLetter,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SettingsSheet(
        soundOn: soundOn,
        hapticsOn: hapticsOn,
        onSoundChanged: onSoundChanged,
        onHapticsChanged: onHapticsChanged,
        onAccountTap: onAccountTap,
        accountLabel: accountLabel,
        avatarLetter: avatarLetter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
        top: AppSpacing.s16,
      ),
      child: PanelCard(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Settings', style: AppTextStyles.subtitle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),

            _SwitchRow(
              title: 'Sound',
              subtitle: 'UI click sounds',
              value: soundOn,
              onChanged: onSoundChanged,
            ),
            _SwitchRow(
              title: 'Haptics',
              subtitle: 'Tap feedback',
              value: hapticsOn,
              onChanged: onHapticsChanged,
            ),

            const SizedBox(height: AppSpacing.s12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _AvatarCircle(letter: avatarLetter),
              title: Text('Account', style: AppTextStyles.body),
              subtitle: Text(accountLabel, style: AppTextStyles.bodyMuted),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                Navigator.pop(context);
                onAccountTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.success,
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMuted),
      secondary: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
