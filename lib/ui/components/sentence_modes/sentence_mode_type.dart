// lib/ui/components/sentence_modes/sentence_mode_type.dart

/// Sentence game variants.
/// These change pressure + interaction, not the core sentence data source.
enum SentenceGameMode {
  classicFill, // your current sentence fill (word bank)
  reconstructionCountdown, // native sentence + shuffled target blocks + distractor + timer
  speedElimination, // target sentence + 4 translations, wrongs disappear over time
}

extension SentenceGameModeLabel on SentenceGameMode {
  String get title {
    switch (this) {
      case SentenceGameMode.classicFill:
        return 'Classic';
      case SentenceGameMode.reconstructionCountdown:
        return 'Reconstruction (Countdown)';
      case SentenceGameMode.speedElimination:
        return 'Speed Elimination';
    }
  }

  String get subtitle {
    switch (this) {
      case SentenceGameMode.classicFill:
        return 'Fill the blank with word bank';
      case SentenceGameMode.reconstructionCountdown:
        return 'Build the target sentence fast (1 distractor)';
      case SentenceGameMode.speedElimination:
        return 'Pick the correct translation before it disappears';
    }
  }
}
