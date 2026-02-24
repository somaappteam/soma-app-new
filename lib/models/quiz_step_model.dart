enum QuizType { vocabMcq }

class QuizStep {
  QuizStep._({
    required this.id,
    required this.type,
    required this.prompt,
    required this.xpReward,
    this.questionWord,
    this.choices,
    this.correctIndex,
  });

  final String id;
  final QuizType type;
  final String prompt;
  final int xpReward;

  final String? questionWord;
  final List<String>? choices;
  final int? correctIndex;

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
}
