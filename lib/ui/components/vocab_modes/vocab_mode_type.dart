// lib/ui/components/vocab_modes/vocab_mode_type.dart

/// Vocabulary game variants (all still MCQ underneath).
/// These change pacing/pressure/scoring, not the word data model.
enum VocabGameMode {
  classicMcq, // your current vocab MCQ
  survivalTimer, // +2 sec correct, -3 sec wrong, ends at 0
  rapidChain, // instant next, combo timer resets after delay
  fallingWords, // word falls, answer before it hits bottom
}

extension VocabGameModeLabel on VocabGameMode {
  String get title {
    switch (this) {
      case VocabGameMode.classicMcq:
        return 'Classic';
      case VocabGameMode.survivalTimer:
        return 'Survival Timer';
      case VocabGameMode.rapidChain:
        return 'Rapid Chain';
      case VocabGameMode.fallingWords:
        return 'Falling Words';
    }
  }

  String get subtitle {
    switch (this) {
      case VocabGameMode.classicMcq:
        return 'Normal vocabulary quiz';
      case VocabGameMode.survivalTimer:
        return 'Stay alive: +2s correct, -3s wrong';
      case VocabGameMode.rapidChain:
        return 'Instant flow: build combo for speed';
      case VocabGameMode.fallingWords:
        return 'Answer before it hits the bottom';
    }
  }

  bool get isCompetitiveDefault => this == VocabGameMode.survivalTimer;
}
