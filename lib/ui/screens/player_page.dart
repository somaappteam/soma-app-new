import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../core/motion/motion.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/spacing.dart';
import '../components/common/app_shell.dart';
import '../components/common/primary_button.dart';
import '../components/quiz/feedback_overlay.dart';
import '../components/quiz/vocab_mcq_widget.dart';
import '../components/vocab_modes/falling_words/falling_words_hud.dart';
import '../components/vocab_modes/falling_words/falling_words_scene.dart';
import '../components/vocab_modes/falling_words_controller.dart';
import '../components/vocab_modes/rapid_chain/rapid_chain_hud.dart';
import '../components/vocab_modes/rapid_chain_controller.dart';
import '../components/vocab_modes/survival_timer/survival_timer_hud.dart';
import '../components/vocab_modes/survival_timer_controller.dart';
import '../components/vocab_modes/vocab_mode_type.dart';
import '../components/world/persistent_world.dart';
import 'result_page.dart';

class PlayerArgs {
  const PlayerArgs({
    required this.mode,
    this.isPractice = false,
    this.vocabMode = VocabGameMode.classicMcq,
  });

  final SessionMode mode;
  final bool isPractice;
  final VocabGameMode vocabMode;

  const PlayerArgs.solo({bool isPractice = false, this.vocabMode = VocabGameMode.classicMcq})
      : mode = SessionMode.solo,
        isPractice = isPractice;

  const PlayerArgs.compete({this.vocabMode = VocabGameMode.survivalTimer})
      : mode = SessionMode.compete,
        isPractice = false;
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.args});

  final PlayerArgs args;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final SessionController session;
  final GlobalKey<VocabMcqWidgetState> _mcqKey = GlobalKey<VocabMcqWidgetState>();

  int correctCount = 0;
  int answeredCount = 0;
  bool _canCheckCurrent = false;

  RapidChainController? rapid;
  FallingWordsController? falling;
  SurvivalTimerController? survival;

  int _autoAdvanceToken = 0;
  bool _showSpeedUpHint = false;

  @override
  void initState() {
    super.initState();
    session = SessionController(mode: SessionMode.solo);
    WorldIntensityController.setFocusMode(true);

    if (widget.args.vocabMode == VocabGameMode.rapidChain) {
      rapid = RapidChainController()..start();
      rapid!.markQuestionShown();
    }
    if (widget.args.vocabMode == VocabGameMode.fallingWords) {
      falling = FallingWordsController()..resetRun();
    }
    if (widget.args.vocabMode == VocabGameMode.survivalTimer) {
      survival = SurvivalTimerController(onTimerComplete: _finishToResults)..start();
    }
  }

  @override
  void dispose() {
    WorldIntensityController.setFocusMode(false);
    session.dispose();
    rapid?.dispose();
    falling?.dispose();
    survival?.dispose();
    super.dispose();
  }

  void _onAnswer(bool correct) {
    if (session.answered) return;

    answeredCount++;
    if (correct) correctCount++;
    session.submitAnswer(correct: correct);

    if (widget.args.vocabMode == VocabGameMode.rapidChain && rapid != null) {
      final event = rapid!.submitAnswer(correct: correct);
      setState(() => _showSpeedUpHint = event.speedUp);
      final token = ++_autoAdvanceToken;
      Future.delayed(Duration(milliseconds: rapid!.pacingMs), () {
        if (!mounted || token != _autoAdvanceToken || !session.answered) return;
        _next();
      });
    }

    if (widget.args.vocabMode == VocabGameMode.survivalTimer && survival != null) {
      correct ? survival!.markCorrect() : survival!.markWrong();
      if (survival!.timeRemainingMs <= 0) {
        _finishToResults();
      }
    }

    if (widget.args.vocabMode == VocabGameMode.fallingWords && falling != null) {
      correct ? falling!.markCorrect() : falling!.markWrong();
    }

    setState(() => _canCheckCurrent = false);
  }

  void _next() {
    if (session.next()) {
      _finishToResults();
      return;
    }

    _showSpeedUpHint = false;
    _canCheckCurrent = false;
    if (rapid != null) {
      rapid!.markQuestionShown();
    }
    setState(() {});
  }

  void _finishToResults() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.result,
      arguments: ResultArgs(
        mode: SessionMode.solo,
        xpGained: correctCount * 10,
        accuracy: answeredCount == 0 ? 0 : correctCount / answeredCount,
        survivalSeconds: survival?.survivedSeconds.toDouble(),
      ),
    );
  }

  Widget _buildHudLane(bool isRapid, bool isSurvival, bool isFalling) {
    Widget child = const SizedBox.shrink();
    if (isRapid && rapid != null) {
      child = RapidChainHud(
        combo: rapid!.combo,
        streak: rapid!.streak,
        pacingMs: rapid!.pacingMs,
        showSpeedUpHint: _showSpeedUpHint,
      );
    } else if (isSurvival && survival != null) {
      child = AnimatedBuilder(
        animation: survival!,
        builder: (context, _) => SurvivalTimerHud(
          timeLeftSeconds: survival!.timeRemainingMs / 1000,
          survivedSeconds: survival!.survivedSeconds.toDouble(),
          lastDeltaMs: survival!.lastBonusMs ??
              (survival!.lastPenaltyMs != null ? -survival!.lastPenaltyMs! : 0),
          showDelta: survival!.lastBonusMs != null || survival!.lastPenaltyMs != null,
        ),
      );
    } else if (isFalling && falling != null) {
      child = AnimatedBuilder(
        animation: falling!,
        builder: (context, _) => FallingWordsHud(
          streak: falling!.streak,
          speedLevel: falling!.speedLevel,
          freezeUsed: falling!.freezeUsed,
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: AnimatedSwitcher(
        duration: AppMotion.snappy,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero).animate(animation);
          return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
        },
        child: KeyedSubtree(
          key: ValueKey('${widget.args.vocabMode.name}-${session.index}'),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRapid = widget.args.vocabMode == VocabGameMode.rapidChain;
    final isSurvival = widget.args.vocabMode == VocabGameMode.survivalTimer;
    final isFalling = widget.args.vocabMode == VocabGameMode.fallingWords;

    final ctaLabel = session.answered ? 'Continue' : 'Check';
    final ctaEnabled = session.answered || (isFalling ? false : _canCheckCurrent);

    return AppShell(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              children: [
                _TopBar(
                  title: widget.args.isPractice ? 'Vocabulary Practice' : 'Vocabulary Lesson',
                  stepLabel: '${session.index + 1}/${session.total}',
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppSpacing.s8),
                _buildHudLane(isRapid, isSurvival, isFalling),
                const SizedBox(height: AppSpacing.s12),
                Expanded(
                  child: isFalling && falling != null
                      ? FallingWordsScene(
                          step: session.current,
                          enabled: !session.answered,
                          controller: falling!,
                          onAnswered: _onAnswer,
                          onFailed: () => _onAnswer(false),
                        )
                      : VocabMcqWidget(
                          key: _mcqKey,
                          step: session.current,
                          enabled: !session.answered,
                          showInlineCheck: false,
                          autoSubmitOnSelect: isRapid,
                          onCanSubmitChanged: (v) {
                            if (_canCheckCurrent == v) return;
                            setState(() => _canCheckCurrent = v);
                          },
                          onSubmit: _onAnswer,
                        ),
                ),
                const SizedBox(height: AppSpacing.s12),
                if (!isRapid)
                  PrimaryButton(
                    label: ctaLabel,
                    onTap: ctaEnabled
                        ? () {
                            if (session.answered) {
                              _next();
                            } else {
                              _mcqKey.currentState?.submitSelection();
                            }
                          }
                        : null,
                  ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: session,
            builder: (context, _) {
              final correct = session.isCorrect;
              return FeedbackOverlay(
                state: correct == null ? FeedbackState.none : (correct ? FeedbackState.correct : FeedbackState.wrong),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.stepLabel, required this.onBack});

  final String title;
  final String stepLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        Text(stepLabel),
      ],
    );
  }
}
