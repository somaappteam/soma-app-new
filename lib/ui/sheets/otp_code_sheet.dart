// lib/ui/sheets/otp_code_sheet.dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/common/app_toast.dart';

/// UI-only OTP verification sheet.
/// You can later connect this to Firebase/Supabase OTP.
/// For now it just "verifies" when 6 digits are entered.
class OtpCodeSheet extends StatefulWidget {
  const OtpCodeSheet({
    super.key,
    required this.email,
    required this.onVerified,
  });

  final String email;
  final VoidCallback onVerified;

  static Future<void> show(
    BuildContext context, {
    required String email,
    required VoidCallback onVerified,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OtpCodeSheet(email: email, onVerified: onVerified),
    );
  }

  @override
  State<OtpCodeSheet> createState() => _OtpCodeSheetState();
}

class _OtpCodeSheetState extends State<OtpCodeSheet> {
  final TextEditingController _code = TextEditingController();
  bool _valid = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool _isValidCode(String v) {
    final s = v.trim();
    return RegExp(r'^\d{6}$').hasMatch(s);
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
                Text('Verify code', style: AppTextStyles.subtitle),
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
              'Enter the 6-digit code sent to:',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(widget.email, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.s16),

            Text('Code', style: AppTextStyles.small),
            const SizedBox(height: AppSpacing.s8),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              style: AppTextStyles.body.copyWith(letterSpacing: 2.0),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
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
              onChanged: (v) => setState(() => _valid = _isValidCode(v)),
              onSubmitted: (_) {
                if (!_isLoading) _verifyIfValid();
              },
            ),

            const SizedBox(height: AppSpacing.s16),

            PrimaryButton(
              label: _isLoading ? 'Verifying...' : 'Verify',
              enabled: _valid && !_isLoading,
              icon: _isLoading ? null : Icons.verified_rounded,
              onTap: (_valid && !_isLoading) ? _verifyIfValid : null,
            ),

            const SizedBox(height: AppSpacing.s12),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  try {
                    await Supabase.instance.client.auth.signInWithOtp(email: widget.email);
                    if (!mounted) return;
                    AppToast.showSuccess(context, 'Code resent!');
                  } catch (e) {
                    if (!mounted) return;
                    AppToast.showError(context, e.toString());
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: Text(
                  'Resend code',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyIfValid() async {
    final code = _code.text.trim();
    if (!_isValidCode(code)) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.email,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onVerified();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
