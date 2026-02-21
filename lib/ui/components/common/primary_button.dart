// lib/ui/components/common/primary_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/text_styles.dart';

/// Primary CTA button with Unity-like "press bounce" and optional glow.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.color = AppColors.primary,
    this.pressedColor = AppColors.primaryPressed,
    this.icon,
    this.haptics = true,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  final Color color;
  final Color pressedColor;

  final IconData? icon;
  final bool haptics;
  final bool fullWidth;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!widget.enabled) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onTap != null;

    final bg = !isEnabled
        ? AppColors.panel2
        : (_pressed ? widget.pressedColor : widget.color);

    final glow = isEnabled && _pressed
        ? AppShadows.softGlow(widget.color)
        : const <BoxShadow>[];

    final scale = _pressed ? AppMotion.pressScale : 1.0;

    final child = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 10),
        ],
        Text(widget.label, style: AppTextStyles.button),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!isEnabled) return;
        if (widget.haptics) HapticFeedback.selectionClick();
        _setPressed(true);
      },
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: isEnabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: scale,
        duration: _pressed ? AppMotion.tapDown : AppMotion.tapUp,
        curve: _pressed ? Curves.easeOutCubic : AppMotion.bounceOut,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.br16,
            boxShadow: [...AppShadows.buttonShadow, ...glow],
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
