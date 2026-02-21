// lib/controllers/vocab_modes/falling_words_controller.dart
import 'package:flutter/foundation.dart';

/// Falling Words controller (UI-only).
/// Keeps game state so PlayerPage can render a HUD consistently.
class FallingWordsController extends ChangeNotifier {
  FallingWordsController({
    this.baseDurationMs = 4200,
    this.minDurationMs = 1400,
  });

  final int baseDurationMs;
  final int minDurationMs;

  int streak = 0;
  bool freezeUsed = false;

  /// Speed level derived from streak (purely for UI display).
  int get speedLevel {
    if (streak >= 18) return 6;
    if (streak >= 14) return 5;
    if (streak >= 10) return 4;
    if (streak >= 6) return 3;
    if (streak >= 3) return 2;
    return 1;
  }

  /// Current falling duration based on streak (faster as streak increases).
  int get fallDurationMs {
    // 5% faster per streak, clamped
    double factor = 1.0;
    final n = streak.clamp(0, 30);
    for (int i = 0; i < n; i++) {
      factor *= 0.95;
    }
    final dur = (baseDurationMs * factor).round();
    return dur.clamp(minDurationMs, baseDurationMs);
  }

  void resetRun() {
    streak = 0;
    freezeUsed = false;
    notifyListeners();
  }

  void markCorrect() {
    streak += 1;
    notifyListeners();
  }

  void markWrong() {
    streak = 0;
    notifyListeners();
  }

  bool canUseFreeze() => !freezeUsed;

  void useFreeze() {
    if (freezeUsed) return;
    freezeUsed = true;
    notifyListeners();
  }
}
