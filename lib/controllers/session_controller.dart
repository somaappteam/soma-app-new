// lib/controllers/session_controller.dart
import 'package:flutter/foundation.dart';
import '../models/quiz_step_model.dart';

enum SessionMode { solo, compete }

/// UI-only session controller.
/// Owns the current set of quiz steps and answer state.
class SessionController extends ChangeNotifier {
  SessionController({required this.mode});

  final SessionMode mode;

  // Session data
  late final List<QuizStep> steps = _demoSteps();
  int index = 0;

  // Answer state
  bool answered = false;
  bool? isCorrect; // null until answered
  int score = 0; // used for compete placeholder

  QuizStep get current => steps[index];
  int get total => steps.length;
  double get progress => (index + 1) / total;

  void reset() {
    index = 0;
    answered = false;
    isCorrect = null;
    score = 0;
    notifyListeners();
  }

  /// Called by quiz widgets when user confirms an answer.
  void submitAnswer({required bool correct, int points = 10}) {
    if (answered) return;
    answered = true;
    isCorrect = correct;

    if (mode == SessionMode.compete && correct) {
      score += points;
    }
    notifyListeners();
  }

  /// Move to next step (after feedback).
  /// Returns true if finished.
  bool next() {
    if (index >= steps.length - 1) {
      return true;
    }
    index += 1;
    answered = false;
    isCorrect = null;
    notifyListeners();
    return false;
  }

  // Demo steps for UI preview
  List<QuizStep> _demoSteps() {
    return [
      QuizStep.vocabMcq(
        id: 'v1',
        prompt: 'Choose the meaning',
        questionWord: 'Apple',
        choices: const ['Apfel', 'Banane', 'Orange', 'Traube'],
        correctIndex: 0,
        xpReward: 10,
      ),
      QuizStep.sentenceFill(
        id: 's1',
        prompt: 'Fill the blank',
        sentenceWithBlank: 'I ___ to school.',
        wordBank: const ['go', 'eat', 'sleep', 'read'],
        correctWord: 'go',
        xpReward: 15,
      ),
      QuizStep.vocabMcq(
        id: 'v2',
        prompt: 'Choose the translation',
        questionWord: 'Thank you',
        choices: const ['Danke', 'Bitte', 'Hallo', 'Tschüss'],
        correctIndex: 0,
        xpReward: 10,
      ),
    ];
  }
}
