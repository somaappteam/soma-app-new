// lib/ui/components/common/course_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/text_styles.dart';

/// Tappable pill that shows current course: "English → Japanese".
/// This should open the Course Switcher bottom sheet.
class CourseChip extends StatefulWidget {
  const CourseChip({
    super.key,
    required this.baseLang,
    required this.targetLang,
    required this.onTap,
  });

  final String baseLang;
  final String targetLang;
  final VoidCallback onTap;

  @override
  State<CourseChip> createState() => _CourseChipState();
}

class _CourseChipState extends State<CourseChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? AppMotion.pressScale : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: _pressed ? AppMotion.tapDown : AppMotion.tapUp,
        curve: _pressed ? Curves.easeOutCubic : AppMotion.bounceOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: AppRadii.pill,
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.public,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.baseLang} → ${widget.targetLang}',
                style: AppTextStyles.chip,
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.expand_more,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
