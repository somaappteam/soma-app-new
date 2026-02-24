import 'package:flutter/material.dart';

import '../../../core/motion/motion_widgets.dart' as motion;

/// Backward-compatible wrapper around shared motion system counter.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
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
    return motion.AnimatedCounter(
      from: from,
      to: to,
      duration: duration,
      curve: curve,
      style: style,
      prefix: prefix,
      suffix: suffix,
    );
  }
}
