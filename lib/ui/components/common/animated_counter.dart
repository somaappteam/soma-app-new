// lib/ui/components/common/animated_counter.dart
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/text_styles.dart';

/// Smooth count-up integer animation (Unity-like).
/// Example: AnimatedCounter(from: 1200, to: 1320)
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 700),
    this.curve = AppMotion.microCurve,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  final int from;
  final int to;
  final Duration duration;
  final Curve curve;

  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from.toDouble(), end: to.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, value, _) {
        final v = value.round();
        return Text('$prefix$v$suffix', style: style ?? AppTextStyles.subtitle);
      },
    );
  }
}
