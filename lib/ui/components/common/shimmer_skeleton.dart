// lib/ui/components/common/shimmer_skeleton.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';

/// Lightweight shimmer skeleton (no external package).
/// Use as a building block for placeholders.
class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 14,
    this.shape = BoxShape.rectangle,
  });

  final double width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0..1
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.radius)
                : null,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * t, 0),
              end: Alignment(1.0 + 2.0 * t, 0),
              colors: [
                AppColors.panel2,
                AppColors.panel.withOpacity(0.85),
                AppColors.panel2,
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
            border: widget.shape == BoxShape.rectangle
                ? Border.all(color: AppColors.panelBorder)
                : null,
          ),
        );
      },
    );
  }
}
