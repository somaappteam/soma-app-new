// lib/ui/components/common/progress_bar.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Reusable stylized progress bar (Unity-like HUD style).
/// Use in Player top bar, lesson cards, profile stats later.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value, // 0..1
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: background,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
