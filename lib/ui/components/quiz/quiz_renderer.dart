import 'package:flutter/material.dart';

import '../../../controllers/session_controller.dart';
import '../../../models/quiz_step_model.dart';
import 'vocab_mcq_widget.dart';

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
    return VocabMcqWidget(
      step: step,
      enabled: !session.answered,
      onSubmit: (correct) => (onAnswer ?? (c) => session.submitAnswer(correct: c))(correct),
    );
  }
}
