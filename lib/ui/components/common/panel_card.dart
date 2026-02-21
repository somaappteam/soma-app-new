// lib/ui/components/common/panel_card.dart
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';

/// Reusable "Unity-style" panel container.
/// Use this for cards, question areas, sheets, and menu blocks.
class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = AppColors.panel,
    this.border = true,
    this.radius = AppRadii.br20,
    this.shadows = AppShadows.panelShadow,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Color color;
  final bool border;
  final BorderRadius radius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: shadows,
        border: border ? Border.all(color: AppColors.panelBorder) : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: padding,
          decoration: const BoxDecoration(
            gradient: AppGradients.panelSheen, // subtle highlight
          ),
          child: child,
        ),
      ),
    );
  }
}
