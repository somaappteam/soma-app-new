// lib/ui/components/quiz/quiz_renderer.dart
import 'package:flutter/material.dart';

import '../../../controllers/session_controller.dart';
import '../../../models/quiz_step_model.dart';
import 'vocab_mcq_widget.dart';
import 'sentence_fill_widget.dart';

/// Chooses which quiz widget to render based on QuizStep.type.
/// This is the main extensibility point: add new cases for new quiz types.
class QuizRenderer extends StatelessWidget {
  const QuizRenderer({
    super.key,
    required this.step,
    required this.session,
    this.onAnswer,
  });

  final QuizStep step;
  final SessionController session;
  final void Function(bool correct)? onAnswer;

  @override
  Widget build(BuildContext context) {
    switch (step.type) {
      case QuizType.vocabMcq:
        return VocabMcqWidget(
          step: step,
          enabled: !session.answered,
          onSubmit: (correct) =>
              (onAnswer ?? (c) => session.submitAnswer(correct: c))(correct),
        );

      case QuizType.sentenceFill:
        return SentenceFillWidget(
          step: step,
          enabled: !session.answered,
          onSubmit: (correct) =>
              (onAnswer ?? (c) => session.submitAnswer(correct: c))(correct),
        );
    }
  }
}
