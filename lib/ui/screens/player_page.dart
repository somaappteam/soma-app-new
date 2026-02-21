// lib/ui/screens/player_page.dart
import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/spacing.dart';
import '../components/common/app_shell.dart';
import '../components/common/panel_card.dart';
import '../components/common/primary_button.dart';
import '../components/quiz/feedback_overlay.dart';
import '../components/quiz/question_header.dart';
import '../components/quiz/quiz_renderer.dart';
import '../components/compete/matchmaking_overlay.dart';
import '../components/common/shimmer_skeleton.dart';
import '../components/compete/skeleton_blocks.dart';
import '../../models/quiz_step_model.dart';
import '../components/vocab_modes/falling_words_controller.dart';
import '../components/vocab_modes/rapid_chain_controller.dart';
import '../components/vocab_modes/survival_timer_controller.dart';
import '../components/vocab_modes/falling_words/falling_words_hud.dart';
import '../components/vocab_modes/falling_words/falling_words_scene.dart';
import '../components/vocab_modes/rapid_chain/rapid_chain_hud.dart';
import '../components/vocab_modes/survival_timer/survival_timer_hud.dart';
import '../components/sentence_modes/sentence_mode_type.dart';
import '../components/sentence_modes/reconstruction/reconstruction_scene.dart';
import '../components/sentence_modes/speed_elimination/speed_elimination_scene.dart';
import '../components/vocab_modes/vocab_mode_banner.dart';
import '../components/vocab_modes/vocab_mode_type.dart';
import 'result_page.dart';

/// Route args for PlayerPage (used by AppRouter).
class PlayerArgs {
  const PlayerArgs({
    required this.mode,
    this.isPractice = false,
    this.vocabMode = VocabGameMode.classicMcq,
    this.sentenceMode = SentenceGameMode.classicFill,
  });

  final SessionMode mode;
  final bool isPractice;
  final VocabGameMode vocabMode;
  final SentenceGameMode sentenceMode;

  const PlayerArgs.solo({
    bool isPractice = false,
    this.vocabMode = VocabGameMode.classicMcq,
    this.sentenceMode = SentenceGameMode.classicFill,
  }) : mode = SessionMode.solo,
       isPractice = isPractice;

  const PlayerArgs.compete({
    this.vocabMode = VocabGameMode.survivalTimer,
    this.sentenceMode = SentenceGameMode.classicFill,
  }) : mode = SessionMode.compete,
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

  // UI-only tracking for results
  int correctCount = 0;
  int answeredCount = 0;

  // Compete UI-only matchmaking overlay
  bool searchingOpponent = false;
  int opponentScore = 0;

  RapidChainController? rapid;
  RapidChainEvent? lastRapidEvent;
  bool showSpeedUpHint = false;

  FallingWordsController? falling;
  SurvivalTimerController? survival;

  int _autoAdvanceToken = 0;

  @override
  void initState() {
    super.initState();
    session = SessionController(mode: widget.args.mode);

    if (widget.args.mode == SessionMode.compete) {
      searchingOpponent = true;
    }

    if (widget.args.vocabMode == VocabGameMode.rapidChain) {
      rapid = RapidChainController();
      rapid!.start();
      rapid!.markQuestionShown();
    }

    if (widget.args.vocabMode == VocabGameMode.fallingWords) {
      falling = FallingWordsController();
      falling!.resetRun();
    }

    if (widget.args.vocabMode == VocabGameMode.survivalTimer) {
      survival = SurvivalTimerController(onTimerComplete: _goToSurvivalResult);
      survival!.start();
    }
  }

  @override
  void dispose() {
    session.dispose();
    rapid?.dispose();
    falling?.dispose();
    survival?.dispose();
    super.dispose();
  }

  FeedbackState get _feedbackState {
    final c = session.isCorrect;
    if (c == null) return FeedbackState.none;
    return c ? FeedbackState.correct : FeedbackState.wrong;
  }

  bool get _rapidActiveForCurrent =>
      rapid != null && session.current.type == QuizType.vocabMcq;

  bool get _fallingActiveForCurrent =>
      widget.args.vocabMode == VocabGameMode.fallingWords &&
      session.current.type == QuizType.vocabMcq;

  bool get _reconstructionActiveForCurrent =>
      widget.args.sentenceMode == SentenceGameMode.reconstructionCountdown &&
      session.current.type == QuizType.sentenceFill;

  bool get _speedElimActiveForCurrent =>
      widget.args.sentenceMode == SentenceGameMode.speedElimination &&
      session.current.type == QuizType.sentenceFill;

  void _handleAnswer(bool correct) {
    // Update Rapid Chain only for vocab steps
    if (_rapidActiveForCurrent) {
      final ev = rapid!.submitAnswer(correct: correct);
      setState(() {
        lastRapidEvent = ev;
        showSpeedUpHint = ev.speedUp;
      });
    }

    if (survival != null && session.current.type == QuizType.vocabMcq) {
      if (correct) {
        survival!.markCorrect();
      } else {
        survival!.markWrong();
      }
    }

    // Always submit into session (drives correct/wrong UI)
    session.submitAnswer(correct: correct);

    // Auto-advance for rapid chain vocab questions
    if (_rapidActiveForCurrent && !searchingOpponent) {
      final myToken = ++_autoAdvanceToken;
      final delayMs = rapid!.pacingMs.clamp(250, 1200);
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        if (myToken != _autoAdvanceToken) return; // cancelled by navigation
        if (!session.answered) return;
        _onNext(context);
      });
    }
  }

  void _goToSurvivalResult() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.result,
      arguments: ResultArgs(
        mode: widget.args.mode,
        xpGained: 120, // UI-only placeholder
        accuracy: answeredCount == 0 ? 0.0 : (correctCount / answeredCount),
        youWon: widget.args.mode == SessionMode.compete
            ? (session.score >= opponentScore)
            : null,
        survivalSeconds: survival?.survivedSeconds.toDouble(),
        bestStreak: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              children: [
                _TopBar(
                  mode: widget.args.mode,
                  title: widget.args.mode == SessionMode.solo
                      ? (widget.args.isPractice ? 'Practice' : 'Lesson')
                      : 'Duel',
                  stepLabel: '${session.index + 1}/${session.total}',
                  progress: session.progress,
                  yourScore: session.score,
                  opponentScore: opponentScore,
                  searchingOpponent: searchingOpponent,
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppSpacing.s12),
                VocabModeBanner(mode: widget.args.vocabMode),
                const SizedBox(height: AppSpacing.s12),

                if (widget.args.vocabMode == VocabGameMode.rapidChain &&
                    _rapidActiveForCurrent) ...[
                  RapidChainHud(
                    combo: rapid!.combo,
                    streak: rapid!.streak,
                    pacingMs: rapid!.pacingMs,
                    showSpeedUpHint: showSpeedUpHint,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],

                if (widget.args.vocabMode == VocabGameMode.survivalTimer &&
                    survival != null) ...[
                  AnimatedBuilder(
                    animation: survival!,
                    builder: (context, _) {
                      return SurvivalTimerHud(
                        timeLeftSeconds: survival!.timeRemainingMs / 1000.0,
                        survivedSeconds: survival!.survivedSeconds.toDouble(),
                        lastDeltaMs: survival!.lastBonusMs ?? (survival!.lastPenaltyMs != null ? -survival!.lastPenaltyMs! : 0),
                        showDelta: survival!.lastBonusMs != null || survival!.lastPenaltyMs != null,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],

                if (widget.args.vocabMode == VocabGameMode.fallingWords &&
                    _fallingActiveForCurrent) ...[
                  AnimatedBuilder(
                    animation: falling!,
                    builder: (context, _) {
                      return FallingWordsHud(
                        streak: falling!.streak,
                        speedLevel: falling!.speedLevel,
                        freezeUsed: falling!.freezeUsed,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],

                QuestionHeader(
                  step: session.current,
                  stepIndex: session.index,
                  totalSteps: session.total,
                ),
                const SizedBox(height: AppSpacing.s16),

                Expanded(
                  child: FeedbackOverlay(
                    state: _feedbackState,
                    child: SingleChildScrollView(
                      child:
                          (widget.args.mode == SessionMode.compete &&
                              searchingOpponent)
                          ? const QuestionCardSkeleton()
                          : _fallingActiveForCurrent
                          ? FallingWordsScene(
                              step: session.current,
                              enabled: !session.answered && !searchingOpponent,
                              controller: falling!,
                              onAnswered: (correct) {
                                _handleAnswer(correct);

                                // auto-advance after short delay
                                Future.delayed(
                                  const Duration(milliseconds: 450),
                                  () {
                                    if (!mounted) return;
                                    if (!session.answered) return;
                                    _onNext(context);
                                  },
                                );
                              },
                              onFailed: () {
                                _handleAnswer(false);

                                // End run on drop
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouter.result,
                                  arguments: ResultArgs(
                                    mode: widget.args.mode,
                                    xpGained: 80, // UI-only placeholder
                                    accuracy: answeredCount == 0
                                        ? 0.0
                                        : (correctCount / answeredCount),
                                    youWon:
                                        widget.args.mode == SessionMode.compete
                                        ? (session.score >= opponentScore)
                                        : null,
                                    survivalSeconds: null,
                                    bestStreak: falling?.streak,
                                  ),
                                );
                              },
                            )
                          : _reconstructionActiveForCurrent
                          ? _buildReconstruction()
                          : _speedElimActiveForCurrent
                          ? _buildSpeedElimination()
                          : QuizRenderer(
                              step: session.current,
                              session: session,
                              onAnswer: _handleAnswer,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.s12),

                if (!((_rapidActiveForCurrent &&
                        widget.args.vocabMode == VocabGameMode.rapidChain) ||
                    _fallingActiveForCurrent ||
                    _reconstructionActiveForCurrent ||
                    _speedElimActiveForCurrent)) ...[
                  PrimaryButton(
                    label: session.answered ? 'Next' : 'Answer to continue',
                    enabled: session.answered && !searchingOpponent,
                    onTap: () => _onNext(context),
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
              ],
            ),
          ),
          if (widget.args.mode == SessionMode.compete)
            MatchmakingOverlay(
              visible: searchingOpponent,
              courseLabel:
                  'English → Japanese', // UI-only; later pass real course
              onCancel: () {
                setState(() => searchingOpponent = false);
                Navigator.pop(context);
              },
              onFinished: () {
                if (!mounted) return;
                setState(() => searchingOpponent = false);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReconstruction() {
    final step = session.current;

    // Use your existing sentence fields (UI-only demo)
    final native =
        (step.prompt.isNotEmpty ? '${step.prompt}: ' : '') +
        (step.sentenceWithBlank ?? 'Translate this sentence');

    // Fill blank if present
    final filled = (step.sentenceWithBlank ?? 'I ___ to school.').replaceAll(
      '___',
      step.correctWord ?? 'go',
    );

    // Tokenize (simple split, remove punctuation)
    final correctTokens = filled
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.trim().isNotEmpty)
        .toList();

    // Pick distractor: from wordBank if possible, else fallback
    final bank = step.wordBank ?? const <String>[];
    String distractor = 'the';
    for (final w in bank) {
      if (!correctTokens.contains(w)) {
        distractor = w;
        break;
      }
    }
    if (correctTokens.contains(distractor)) distractor = 'and';

    return ReconstructionScene(
      nativeSentence: native,
      targetTokensCorrect: correctTokens,
      distractorToken: distractor,
      seconds: 12,
      enabled: !session.answered && !searchingOpponent,
      onAnswered: (correct) {
        _handleAnswer(correct);

        // auto-advance after short delay
        Future.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          if (!session.answered) return;
          _onNext(context);
        });
      },
      onTimeout: () {
        // timeout counts as wrong
        _handleAnswer(false);

        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          _onNext(context);
        });
      },
    );
  }

  Widget _buildSpeedElimination() {
    final step = session.current;

    // Create a "target sentence" (fill blank)
    final target = (step.sentenceWithBlank ?? 'I ___ to school.').replaceAll(
      '___',
      step.correctWord ?? 'go',
    );

    // Better UI-only distractors built from the target sentence
    final words = target
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    String makeDistractor(int n) {
      if (words.isEmpty) return 'Wrong option $n';
      final copy = List<String>.from(words);

      // Small mutations so they look real:
      // - swap two words (n=1)
      // - replace one word with a blank (n=2)
      // - drop last word (n=3)
      if (copy.length >= 2 && n == 1) {
        final tmp = copy[0];
        copy[0] = copy[1];
        copy[1] = tmp;
      } else if (copy.isNotEmpty && n == 2) {
        copy[copy.length ~/ 2] = '___';
      } else if (copy.length >= 3 && n == 3) {
        copy.removeAt(copy.length - 1);
      }

      return copy.join(' ');
    }

    final correctNative = step.prompt.isNotEmpty
        ? step.prompt
        : 'Correct translation';

    final options = <String>[
      correctNative,
      makeDistractor(1),
      makeDistractor(2),
      makeDistractor(3),
    ];

    // shuffle but keep track of correct index
    final shuffled = List<String>.from(options);
    shuffled.shuffle();
    final newCorrectIndex = shuffled.indexOf(correctNative);

    return SpeedEliminationScene(
      targetSentence: target,
      optionsNative: shuffled,
      correctIndex: newCorrectIndex,
      seconds: 10,
      enabled: !session.answered && !searchingOpponent,
      onAnswered: (correct) {
        _handleAnswer(correct);

        Future.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          if (!session.answered) return;
          _onNext(context);
        });
      },
      onTimeout: () {
        _handleAnswer(false);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          _onNext(context);
        });
      },
    );
  }

  void _onNext(BuildContext context) {
    // Record result of current step (once per step)
    if (session.isCorrect != null) {
      answeredCount += 1;
      if (session.isCorrect == true) correctCount += 1;

      // UI-only opponent scoring: random-ish (simple)
      if (widget.args.mode == SessionMode.compete) {
        opponentScore += 8; // placeholder
      }
    }

    final finished = session.next();
    if (finished) {
      final accuracy = answeredCount == 0
          ? 0.0
          : (correctCount / answeredCount);

      Navigator.pushReplacementNamed(
        context,
        AppRouter.result,
        arguments: ResultArgs(
          mode: widget.args.mode,
          xpGained: 120, // UI-only placeholder
          accuracy: accuracy,
          youWon: widget.args.mode == SessionMode.compete
              ? (session.score >= opponentScore)
              : null,

          // arcade stats (optional)
          survivalSeconds:
              (widget.args.vocabMode == VocabGameMode.survivalTimer &&
                  survival != null)
              ? survival!.survivedSeconds.toDouble()
              : null,
          bestStreak:
              (widget.args.vocabMode == VocabGameMode.rapidChain &&
                  rapid != null)
              ? rapid!.bestCombo
              : (widget.args.vocabMode == VocabGameMode.fallingWords &&
                    falling != null)
              ? falling!.streak
              : null,
        ),
      );
    } else {
      setState(() {}); // refresh UI for next step
      rapid?.markQuestionShown();
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mode,
    required this.title,
    required this.stepLabel,
    required this.progress,
    required this.yourScore,
    required this.opponentScore,
    required this.searchingOpponent,
    required this.onBack,
  });

  final SessionMode mode;
  final String title;
  final String stepLabel;
  final double progress;

  final int yourScore;
  final int opponentScore;

  final bool searchingOpponent;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.subtitle),
                    const SizedBox(width: 10),
                    Text(stepLabel, style: AppTextStyles.small),
                    const Spacer(),
                    if (mode == SessionMode.compete)
                      searchingOpponent
                          ? const OpponentSkeleton()
                          : _DuelScorePills(
                              searching: searchingOpponent,
                              you: yourScore,
                              them: opponentScore,
                            ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.panel2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mode == SessionMode.compete
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuelScorePills extends StatelessWidget {
  const _DuelScorePills({
    required this.searching,
    required this.you,
    required this.them,
  });

  final bool searching;
  final int you;
  final int them;

  @override
  Widget build(BuildContext context) {
    if (searching) {
      return Row(
        children: [
          const Icon(
            Icons.wifi_tethering_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text('Finding…', style: AppTextStyles.small),
        ],
      );
    }

    return Row(
      children: [
        _ScorePill(label: 'You', value: you, color: AppColors.success),
        const SizedBox(width: 8),
        _ScorePill(label: 'Them', value: them, color: AppColors.danger),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label $value', style: AppTextStyles.small),
        ],
      ),
    );
  }
}
