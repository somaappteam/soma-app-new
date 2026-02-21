// lib/ui/screens/home_page.dart
import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/action_card.dart';
import '../components/common/app_shell.dart';
import '../components/common/app_toast.dart';
import '../components/common/continue_card.dart';
import '../components/common/hud_bar.dart';
import '../sheets/course_switcher_sheet.dart';
import '../sheets/settings_sheet.dart';
import 'player_page.dart';
import '../components/common/focus_chip.dart';
import '../sheets/focus_picker_sheet.dart';
import '../sheets/sign_in_sheet.dart';
import '../sheets/email_entry_sheet.dart';
import '../sheets/otp_code_sheet.dart';
import '../sheets/vocab_mode_picker_sheet.dart';
import '../components/vocab_modes/vocab_mode_type.dart';
import '../sheets/sentence_mode_picker_sheet.dart';
import '../components/sentence_modes/sentence_mode_type.dart';

/// Home hub: only 3 actions (Continue / Practice / Compete).
/// UI-only state is stored in a simple AppController instance.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // UI-only global-ish state for now.
  // Later: lift this into a provider / DI.
  final AppController app = AppController();

  LearningFocus focus = LearningFocus.mix;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      hud: HudBar(
        baseLang: app.baseLang,
        targetLang: app.targetLang,
        xp: app.xp,
        streak: app.streak,
        onCourseTap: () => _openCourseSwitcher(context),
        onSettingsTap: () => _openSettings(context),
        avatarLetter: app.isLoggedIn
            ? (app.displayName.trim().isNotEmpty
                  ? app.displayName.trim()[0].toUpperCase()
                  : 'U')
            : 'G',
        onAvatarTap: () => _openSettings(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.s8),

            ContinueCard(
              focus: focus,
              progress: 0.35, // UI-only for now (later from progress)
              etaText: focus == LearningFocus.vocabulary ? '1 min' : '2 min',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.player,
                  arguments: PlayerArgs.solo(
                    isPractice: false,
                    vocabMode: app.vocabMode,
                    sentenceMode: app.sentenceMode,
                  ),
                );
              },
              onFocusTap: () {
                FocusPickerSheet.show(
                  context,
                  current: focus,
                  onSelected: (f) => setState(() => focus = f),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s12),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    title: 'Practice',
                    subtitle: 'Quick review • 90 sec',
                    icon: Icons.bolt_rounded,
                    accent: AppColors.success,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.player,
                        arguments: PlayerArgs.solo(
                          isPractice: true,
                          vocabMode: app.vocabMode,
                          sentenceMode: app.sentenceMode,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: ActionCard(
                    title: 'Compete',
                    subtitle: '1v1 quick match',
                    icon: Icons.sports_esports_rounded,
                    accent: AppColors.secondary,
                    onTap: () {
                      if (!app.isLoggedIn) {
                        SignInSheet.show(
                          context,
                          onGoogle: () =>
                              setState(() => app.signInAs('Alex (Google)')),
                          onApple: () =>
                              setState(() => app.signInAs('Alex (Apple)')),
                          onEmail: _startEmailOtpSignIn,
                          onSkip: () {
                            // stay on Home, do nothing
                            AppToast.showInfo(context, 'Continue in Solo mode');
                          },
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        AppRouter.player,
                        arguments: PlayerArgs.compete(
                          vocabMode: app.vocabMode,
                          sentenceMode: app.sentenceMode,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  VocabModePickerSheet.show(
                    context,
                    current: app.vocabMode,
                    onSelected: (m) => setState(() => app.setVocabMode(m)),
                  );
                },
                child: Text(
                  'Vocabulary mode: ${app.vocabMode.title}  ▾',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  SentenceModePickerSheet.show(
                    context,
                    current: app.sentenceMode,
                    onSelected: (m) => setState(() => app.setSentenceMode(m)),
                  );
                },
                child: Text(
                  'Sentence mode: ${app.sentenceMode.title}  ▾',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s24),

            Text('Keep it simple', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'One course. Three actions. Fast learning.',
              style: AppTextStyles.bodyMuted,
            ),

            const SizedBox(height: AppSpacing.s24),

            TextButton(
              onPressed: () {
                // UI-only placeholder
                AppToast.showInfo(context, 'Progress (UI-only placeholder)');
              },
              child: const Text('Progress'),
            ),
          ],
        ),
      ),
    );
  }

  void _startEmailOtpSignIn() {
    EmailEntrySheet.show(
      context,
      onSendCode: (email) {
        // After "sending code", open OTP sheet
        OtpCodeSheet.show(
          context,
          email: email,
          onVerified: () {
            AppToast.showSuccess(context, 'Signed in successfully');
          },
        );
      },
    );
  }

  Future<void> _openCourseSwitcher(BuildContext context) async {
    await CourseSwitcherSheet.show(
      context,
      activeCourse: app.activeCourseLabel,
      courses: app.courses,
      onSelectCourse: (label) => setState(() => app.selectCourseLabel(label)),
      onAddCourse: () async {
        // Simple add flow (UI-only): pick base & target from a tiny list.
        final base = await _pickQuickLanguage(context, title: 'I speak');
        if (base == null) return;
        final target = await _pickQuickLanguage(context, title: "I'm learning");
        if (target == null) return;
        setState(() => app.addCourse(base, target));
      },
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await SettingsSheet.show(
      context,
      soundOn: app.soundOn,
      hapticsOn: app.hapticsOn,
      onSoundChanged: (v) => setState(() => app.setSound(v)),
      onHapticsChanged: (v) => setState(() => app.setHaptics(v)),
      onAccountTap: () {
        if (!app.isLoggedIn) {
          SignInSheet.show(
            context,
            onGoogle: () => setState(() => app.signInAs('Alex (Google)')),
            onApple: () => setState(() => app.signInAs('Alex (Apple)')),
            onEmail: _startEmailOtpSignIn,
            onSkip: () {},
          );
        } else {
          setState(() => app.signOut());
          AppToast.showInfo(context, 'Signed out');
        }
      },
      accountLabel: app.isLoggedIn
          ? 'Signed in as ${app.displayName}'
          : 'Guest (sign in to compete)',
      avatarLetter: app.isLoggedIn
          ? (app.displayName.trim().isNotEmpty
                ? app.displayName.trim()[0].toUpperCase()
                : 'U')
          : 'G',
    );
  }

  Future<String?> _pickQuickLanguage(
    BuildContext context, {
    required String title,
  }) {
    const langs = [
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

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickPickSheet(title: title, items: langs),
    );
  }
}

class _QuickPickSheet extends StatelessWidget {
  const _QuickPickSheet({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelBorder),
      ),
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
          ...items.map(
            (x) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(x, style: AppTextStyles.body),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              onTap: () => Navigator.pop(context, x),
            ),
          ),
        ],
      ),
    );
  }
}
