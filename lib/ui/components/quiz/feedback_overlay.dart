// lib/ui/components/quiz/feedback_overlay.dart
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';

/// Wrap any content with Unity-like feedback:
/// - Correct: quick pulse + soft green glow overlay
/// - Wrong: shake + soft red flash overlay
///
/// Usage:
/// FeedbackOverlay(
///   state: session.isCorrect == null ? FeedbackState.none
///          : (session.isCorrect! ? FeedbackState.correct : FeedbackState.wrong),
///   child: YourQuizWidget(),
/// )
enum FeedbackState { none, correct, wrong }

class FeedbackOverlay extends StatefulWidget {
  const FeedbackOverlay({super.key, required this.state, required this.child});

  final FeedbackState state;
  final Widget child;

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: AppMotion.shake,
  );

  @override
  void didUpdateWidget(covariant FeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake only when transitioning into wrong.
    if (oldWidget.state != FeedbackState.wrong &&
        widget.state == FeedbackState.wrong) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.state == FeedbackState.correct;
    final isWrong = widget.state == FeedbackState.wrong;

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final t = _shakeCtrl.value;

        // Shake pattern: +10, -10, +7, -7, 0 (approx)
        final dx = isWrong ? _shakeDx(t) : 0.0;

        return Transform.translate(
          offset: Offset(dx, 0),
          child: Stack(
            children: [
              // Pulse effect (correct only)
              AnimatedScale(
                scale: isCorrect ? 1.02 : 1.0,
                duration: AppMotion.pulse,
                curve: AppMotion.microCurve,
                child: child,
              ),

              // Color flash overlay
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: isCorrect || isWrong ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.danger.withOpacity(0.14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  double _shakeDx(double t) {
    // Piecewise-ish shake using sine for smoothness
    // Strongest at start, settles to 0.
    final strength = (1.0 - t) * 10.0; // max 10px
    final oscillation = (t * 6.0) * 3.14159; // ~3 waves
    return strength * (sinApprox(oscillation));
  }

  // Simple sine approximation to avoid importing dart:math.
  // Good enough for UI shake.
  double sinApprox(double x) {
    // wrap to [-pi, pi]
    const pi = 3.1415926535897932;
    while (x > pi) x -= 2 * pi;
    while (x < -pi) x += 2 * pi;

    // 5th-order Taylor approximation
    final x2 = x * x;
    return x * (1 - x2 / 6 + (x2 * x2) / 120);
  }
}
