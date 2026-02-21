// lib/ui/screens/setup_page.dart
import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/colors.dart';
import '../components/common/app_shell.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';

/// First-time setup (UI-only).
/// Lets user choose base + target language and mode.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String baseLang = 'English';
  String targetLang = 'Japanese';

  bool compete = false;

  final List<String> languages = const [
    'English',
    'Portuguese',
    'French',
    'Spanish',
    'Arabic',
    'Swahili',
    'Japanese',
    'Korean',
    'German',
  ];

  Future<void> _pickLang({required bool pickBase}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(
        title: pickBase ? 'I speak' : "I'm learning",
        languages: languages,
      ),
    );
    if (selected == null) return;
    setState(() {
      if (pickBase) {
        baseLang = selected;
      } else {
        targetLang = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s16),
            Text('Choose your course', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Pick what you speak and what you want to learn.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s24),

            PanelCard(
              child: Column(
                children: [
                  _SelectorRow(
                    title: 'I speak',
                    value: baseLang,
                    onTap: () => _pickLang(pickBase: true),
                  ),
                  const Divider(color: AppColors.panelBorder, height: 24),
                  _SelectorRow(
                    title: "I'm learning",
                    value: targetLang,
                    onTap: () => _pickLang(pickBase: false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            PanelCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      compete ? 'Mode: Compete' : 'Mode: Solo',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  _ModeToggle(
                    compete: compete,
                    onChanged: (v) => setState(() => compete = v),
                  ),
                ],
              ),
            ),

            const Spacer(),

            PrimaryButton(
              label: 'Start',
              onTap: () {
                // UI-only: just navigate Home. Later you’ll store base/target/mode in AppController.
                Navigator.pushReplacementNamed(context, AppRouter.home);
              },
              icon: Icons.play_arrow_rounded,
            ),
            const SizedBox(height: AppSpacing.s12),
            Center(
              child: Text(
                'You can change course anytime from Home.',
                style: AppTextStyles.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.small),
                  const SizedBox(height: 6),
                  Text(value, style: AppTextStyles.body),
                ],
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.compete, required this.onChanged});
  final bool compete;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: 'Solo', active: !compete, onTap: () => onChanged(false)),
          _Pill(
            label: 'Compete',
            active: compete,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: active ? AppTextStyles.body : AppTextStyles.bodyMuted,
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.title, required this.languages});

  final String title;
  final List<String> languages;

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
                Text(title, style: AppTextStyles.subtitle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            ...languages.map(
              (l) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l, style: AppTextStyles.body),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
                onTap: () => Navigator.pop(context, l),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
