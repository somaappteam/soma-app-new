import 'package:flutter/material.dart';

import '../../../core/motion/motion_widgets.dart';
import '../../../core/theme/colors.dart';

/// Reusable stylized progress bar with shared animated progress motion.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color = AppColors.primary,
    this.background = AppColors.panel2,
  });

  final double value;
  final double height;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AnimatedProgress(
      value: value,
      builder: (context, animatedValue) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}
