// lib/controllers/vocab_modes/rapid_chain_controller.dart
import 'package:flutter/foundation.dart';

/// Rapid Chain (Reflex Mode) controller (UI-only).
///
/// Core rules:
/// - Every answer immediately advances to next word (handled by PlayerPage later)
/// - Combo increases on fast correct answers
/// - If user takes > comboWindowMs OR answers wrong -> combo resets
/// - After 10 streak, pacing gets slightly faster (you can use pacingMs in UI)
class RapidChainController extends ChangeNotifier {
  RapidChainController({
    this.comboWindowMs = 2000,
    this.basePacingMs = 700,
    this.minPacingMs = 420,
  });

  /// If time between question reveal and answer is > this, combo resets.
  final int comboWindowMs;

  /// UI hint: how fast the mode should feel (lower is faster).
  final int basePacingMs;

  /// Don’t speed up beyond this.
  final int minPacingMs;

  int combo = 0;
  int bestCombo = 0;

  int streak = 0; // correct streak
  int totalAnswered = 0;
  int totalCorrect = 0;

  /// A UI pacing hint. You can use it to shorten delays/animations as streak grows.
  int pacingMs = 700;

  /// Used to detect “2 sec delay = combo reset”
  DateTime? _questionShownAt;

  void start() {
    combo = 0;
    bestCombo = 0;
    streak = 0;
    totalAnswered = 0;
    totalCorrect = 0;
    pacingMs = basePacingMs;
    _questionShownAt = DateTime.now();
    notifyListeners();
  }

  /// Call when a new word/question is shown.
  void markQuestionShown() {
    _questionShownAt = DateTime.now();
  }

  /// Submit an answer result.
  ///
  /// Pass `correct=true/false`.
  /// Optionally pass `responseTimeMs` if you already measured it; otherwise we compute it.
  ///
  /// Returns a small event object that PlayerPage can use to show UI feedback.
  RapidChainEvent submitAnswer({required bool correct, int? responseTimeMs}) {
    final now = DateTime.now();
    final rt =
        responseTimeMs ??
        (_questionShownAt == null
            ? 0
            : now.difference(_questionShownAt!).inMilliseconds);

    totalAnswered += 1;

    bool comboReset = false;
    bool speedUp = false;

    if (!correct) {
      // wrong: reset
      combo = 0;
      streak = 0;
      comboReset = true;
    } else {
      totalCorrect += 1;

      // delayed too long: combo reset (but still counts as correct for streak?)
      // Your rule says: "2 sec delay = combo reset" and "encourages mastery"
      // We'll keep streak for correctness, but reset combo for slowness.
      if (rt > comboWindowMs) {
        combo = 0;
        comboReset = true;
      }

      // Increase streak always for correct
      streak += 1;

      // Only increase combo if fast enough
      if (rt <= comboWindowMs) {
        combo += 1;
      }

      if (combo > bestCombo) bestCombo = combo;

      // After 10 streak: slightly faster pacing
      if (streak >= 10) {
        final next = (pacingMs * 0.95).round(); // 5% faster each time after 10
        final clamped = next < minPacingMs ? minPacingMs : next;
        if (clamped != pacingMs) {
          pacingMs = clamped;
          speedUp = true;
        }
      }
    }

    // For next question
    _questionShownAt = DateTime.now();

    notifyListeners();

    return RapidChainEvent(
      correct: correct,
      responseTimeMs: rt,
      combo: combo,
      streak: streak,
      comboReset: comboReset,
      speedUp: speedUp,
      pacingMs: pacingMs,
    );
  }
}

/// Small UI event returned after each answer.
/// PlayerPage can use it to show "Combo reset" or "Speed up!" messages.
class RapidChainEvent {
  RapidChainEvent({
    required this.correct,
    required this.responseTimeMs,
    required this.combo,
    required this.streak,
    required this.comboReset,
    required this.speedUp,
    required this.pacingMs,
  });

  final bool correct;
  final int responseTimeMs;
  final int combo;
  final int streak;
  final bool comboReset;
  final bool speedUp;
  final int pacingMs;
}
