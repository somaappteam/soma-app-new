// lib/models/quiz_step_model.dart
enum QuizType { vocabMcq, sentenceFill }

/// A single quiz step. PlayerPage renders it via QuizRenderer.
/// Designed to be extensible: add new types later without changing pages.
class QuizStep {
  QuizStep._({
    required this.id,
    required this.type,
    required this.prompt,
    required this.xpReward,
    // vocab mcq
    this.questionWord,
    this.choices,
    this.correctIndex,
    // sentence fill
    this.sentenceWithBlank,
    this.wordBank,
    this.correctWord,
  });

  final String id;
  final QuizType type;
  final String prompt;
  final int xpReward;

  // --- Vocab MCQ fields ---
  final String? questionWord;
  final List<String>? choices;
  final int? correctIndex;

  // --- Sentence Fill fields ---
  final String? sentenceWithBlank; // e.g. "I ___ to school."
  final List<String>? wordBank;
  final String? correctWord;

  // Factories
  factory QuizStep.vocabMcq({
    required String id,
    required String prompt,
    required String questionWord,
    required List<String> choices,
    required int correctIndex,
    required int xpReward,
  }) {
    return QuizStep._(
      id: id,
      type: QuizType.vocabMcq,
      prompt: prompt,
      xpReward: xpReward,
      questionWord: questionWord,
      choices: choices,
      correctIndex: correctIndex,
    );
  }

  factory QuizStep.sentenceFill({
    required String id,
    required String prompt,
    required String sentenceWithBlank,
    required List<String> wordBank,
    required String correctWord,
    required int xpReward,
  }) {
    return QuizStep._(
      id: id,
      type: QuizType.sentenceFill,
      prompt: prompt,
      xpReward: xpReward,
      sentenceWithBlank: sentenceWithBlank,
      wordBank: wordBank,
      correctWord: correctWord,
    );
  }
}
