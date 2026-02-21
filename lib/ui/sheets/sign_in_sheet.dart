// lib/ui/sheets/sign_in_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';

/// UI-only Sign In sheet.
/// Use this when user taps Compete while not logged in, or from Settings -> Account.
class SignInSheet extends StatelessWidget {
  const SignInSheet({
    super.key,
    required this.onGoogle,
    required this.onApple,
    required this.onEmail,
    required this.onSkip,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onEmail;
  final VoidCallback onSkip;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onGoogle,
    required VoidCallback onApple,
    required VoidCallback onEmail,
    required VoidCallback onSkip,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SignInSheet(
        onGoogle: onGoogle,
        onApple: onApple,
        onEmail: onEmail,
        onSkip: onSkip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        top: AppSpacing.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
      ),
      child: PanelCard(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sign in to compete', style: AppTextStyles.subtitle),
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
              'Save your progress and play online with other learners.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s16),

            PrimaryButton(
              label: 'Continue with Google',
              onTap: () {
                Navigator.pop(context);
                onGoogle();
              },
              icon: Icons.g_mobiledata_rounded,
            ),
            const SizedBox(height: AppSpacing.s12),

            PrimaryButton(
              label: 'Continue with Apple',
              onTap: () {
                Navigator.pop(context);
                onApple();
              },
              icon: Icons.apple_rounded,
              color: AppColors.panel,
              pressedColor: AppColors.panel2,
            ),
            const SizedBox(height: AppSpacing.s12),

            PrimaryButton(
              label: 'Continue with Email',
              onTap: () {
                Navigator.pop(context);
                onEmail();
              },
              icon: Icons.email_rounded,
              color: AppColors.secondary,
              pressedColor: AppColors.secondaryPressed,
            ),

            const SizedBox(height: AppSpacing.s12),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSkip();
                },
                child: Text(
                  'Not now (Solo only)',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s4),
            Center(
              child: Text(
                'No passwords needed (you can add later).',
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
