import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../core/data/languages.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/spacing.dart';
import '../components/common/app_shell.dart';
import '../components/common/continue_card.dart';
import '../components/common/hud_bar.dart';
import '../components/home/daily_goal_card.dart';
import '../components/home/game_mode_grid.dart';
import '../sheets/course_switcher_sheet.dart';
import 'player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.app, this.onProfileTap});

  final AppController app;
  final VoidCallback? onProfileTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppController app;

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
        onProfileTap: widget.onProfileTap,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.s8),
            DailyGoalCard(currentXp: app.xp, streak: app.streak),
            const SizedBox(height: AppSpacing.s16),
            ContinueCard(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.player,
                  arguments: PlayerArgs.solo(isPractice: false, vocabMode: app.vocabMode),
                );
              },
              progress: 0.35,
              etaText: '1 min',
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
        final base = await _pickQuickLanguage(context, title: 'I speak');
        if (base == null) return;
        final target = await _pickQuickLanguage(context, title: 'I want to learn');
        if (target == null) return;
        if (!mounted) return;
        setState(() => app.addCourse(base, target));
      },
    );
  }

  Future<String?> _pickQuickLanguage(BuildContext context, {required String title}) async {
    const langs = appLanguages;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2B3043)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                child: Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF9AA3B2)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x332B3043)),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: langs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x1AFFFFFF)),
                  itemBuilder: (_, i) {
                    final l = langs[i];
                    return ListTile(
                      title: Text(l.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(l.code, style: const TextStyle(color: Color(0xFF9AA3B2))),
                      onTap: () => Navigator.pop(ctx, l.name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
