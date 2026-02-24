import 'package:flutter/foundation.dart';

import '../models/quiz_step_model.dart';

enum SessionMode { solo, compete }

class SessionController extends ChangeNotifier {
  SessionController({required this.mode});

  final SessionMode mode;

  late final List<QuizStep> steps = _demoSteps();
  int index = 0;

  bool answered = false;
  bool? isCorrect;
  int score = 0;

  QuizStep get current => steps[index];
  int get total => steps.length;
  double get progress => (index + 1) / total;

  void submitAnswer({required bool correct, int points = 10}) {
    if (answered) return;
    answered = true;
    isCorrect = correct;
    if (correct) score += points;
    notifyListeners();
  }

  bool next() {
    if (index >= steps.length - 1) return true;
    index += 1;
    answered = false;
    isCorrect = null;
    notifyListeners();
    return false;
  }

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
      QuizStep.vocabMcq(
        id: 'v2',
        prompt: 'Choose the translation',
        questionWord: 'Thank you',
        choices: const ['Danke', 'Bitte', 'Hallo', 'Tschüss'],
        correctIndex: 0,
        xpReward: 10,
      ),
      QuizStep.vocabMcq(
        id: 'v3',
        prompt: 'Pick the right word',
        questionWord: 'Good night',
        choices: const ['Gute Nacht', 'Guten Morgen', 'Willkommen', 'Bis später'],
        correctIndex: 0,
        xpReward: 10,
      ),
    ];
  }
}
