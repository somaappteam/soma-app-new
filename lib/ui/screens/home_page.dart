// lib/ui/screens/home_page.dart
import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/home/daily_goal_card.dart';
import '../components/home/game_mode_grid.dart';
import '../components/common/app_shell.dart';
import '../components/common/continue_card.dart';
import '../components/common/hud_bar.dart';
import '../sheets/course_switcher_sheet.dart';
import 'player_page.dart';
import '../components/common/focus_chip.dart';
import '../sheets/focus_picker_sheet.dart';


/// Home hub: only 3 actions (Continue / Practice / Compete).
/// UI-only state is stored in a simple AppController instance.
class HomePage extends StatefulWidget {
  final AppController app;
  const HomePage({super.key, required this.app});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppController app;
  LearningFocus focus = LearningFocus.mix;

  @override
  void initState() {
    super.initState();
    app = widget.app;
    app.addListener(_onAppChanged);
  }

  @override
  void dispose() {
    app.removeListener(_onAppChanged);
    super.dispose();
  }

  void _onAppChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      hud: HudBar(
        baseLang: app.baseLang,
        targetLang: app.targetLang,
        xp: app.xp,
        streak: app.streak,
        onCourseTap: () => _openCourseSwitcher(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.s8),

            DailyGoalCard(
              currentXp: app.xp,
              streak: app.streak,
            ),
            const SizedBox(height: AppSpacing.s16),

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
            const SizedBox(height: AppSpacing.s32),

            const GameModeGrid(),
            
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
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
