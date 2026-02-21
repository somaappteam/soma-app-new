// lib/ui/sheets/email_entry_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';

/// UI-only Email entry for OTP login/signup.
/// Flow:
/// 1) User enters email
/// 2) You "send code" (UI-only)
/// 3) Open OtpCodeSheet
class EmailEntrySheet extends StatefulWidget {
  const EmailEntrySheet({super.key, required this.onSendCode});

  /// Called with the email when user taps Continue.
  final ValueChanged<String> onSendCode;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSendCode,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EmailEntrySheet(onSendCode: onSendCode),
    );
  }

  @override
  State<EmailEntrySheet> createState() => _EmailEntrySheetState();
}

class _EmailEntrySheetState extends State<EmailEntrySheet> {
  final TextEditingController _email = TextEditingController();
  bool _valid = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    return s.contains('@') && s.contains('.') && s.length >= 6;
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
                Text('Continue with Email', style: AppTextStyles.subtitle),
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
              'We’ll send a 6-digit code to your email. New email = new account.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s16),

            Text('Email', style: AppTextStyles.small),
            const SizedBox(height: AppSpacing.s8),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.body,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'name@example.com',
                hintStyle: AppTextStyles.bodyMuted,
                filled: true,
                fillColor: AppColors.panel2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.panelBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.panelBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (v) => setState(() => _valid = _isValidEmail(v)),
              onSubmitted: (_) => _submitIfValid(),
            ),

            const SizedBox(height: AppSpacing.s16),

            PrimaryButton(
              label: 'Send code',
              enabled: _valid,
              icon: Icons.mail_rounded,
              onTap: _valid ? _submitIfValid : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submitIfValid() {
    final email = _email.text.trim();
    if (!_isValidEmail(email)) return;
    Navigator.pop(context);
    widget.onSendCode(email);
  }
}
