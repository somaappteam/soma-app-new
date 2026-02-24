import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/app_shell.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';
import '../sheets/sign_in_sheet.dart';
import '../sheets/email_entry_sheet.dart';
import '../sheets/otp_code_sheet.dart';

class ProfilePage extends StatefulWidget {
  final AppController app;
  final VoidCallback? onBack;
  const ProfilePage({super.key, required this.app, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    widget.app.addListener(_onAppChanged);
  }

  @override
  void dispose() {
    widget.app.removeListener(_onAppChanged);
    super.dispose();
  }

  void _onAppChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: ListView(
          children: [
            if (widget.onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: AppSpacing.s16),
            if (!widget.app.isLoggedIn) _buildSignedOutBanner(context) else _buildProfileHeader(),
            const SizedBox(height: AppSpacing.s32),
            Text('Statistics', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: PanelCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text('${widget.app.streak}', style: AppTextStyles.title),
                        Text('Day Streak', style: AppTextStyles.small),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: PanelCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      children: [
                        Icon(Icons.bolt_rounded, color: AppColors.accent),
                        const SizedBox(height: 8),
                        Text('${widget.app.xp}', style: AppTextStyles.title),
                        Text('Total XP', style: AppTextStyles.small),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s32),
            Text('Preferences', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.s12),
            PanelCard(
              child: Column(
                children: [
                   SwitchListTile(
                    title: Text('Sound effects', style: AppTextStyles.body),
                    value: widget.app.soundOn,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => widget.app.setSound(v),
                  ),
                  const Divider(color: AppColors.panelBorder, height: 1),
                  SwitchListTile(
                    title: Text('Haptics', style: AppTextStyles.body),
                    value: widget.app.hapticsOn,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => widget.app.setHaptics(v),
                  ),
                ],
              ),
            ),
            if (widget.app.isLoggedIn) ...[
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    widget.app.signOut();
                  },
                  child: Text(
                    'Sign Out',
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOutBanner(BuildContext context) {
    return PanelCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_sync_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Save Your Progress',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Create a free account to sync your streak and XP across devices.',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s24),
          PrimaryButton(
            label: 'Sign In / Sign Up',
            onTap: () {
              SignInSheet.show(
                context,
                onGoogle: () {},
                onApple: () {},
                onEmail: () {
                  EmailEntrySheet.show(
                    context,
                    onSendCode: (email) {
                      OtpCodeSheet.show(
                        context,
                        email: email,
                        onVerified: () {},
                      );
                    },
                  );
                },
                onSkip: () {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initial = widget.app.displayName.isNotEmpty ? widget.app.displayName[0].toUpperCase() : 'U';
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: Text(
            initial,
            style: AppTextStyles.title.copyWith(fontSize: 28),
          ),
        ),
        const SizedBox(width: AppSpacing.s20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.app.displayName,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 4),
              Text(
                'Language Learner',
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
