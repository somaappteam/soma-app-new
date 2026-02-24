import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/motion/motion_widgets.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/text_styles.dart';

/// Primary CTA button with shared SquishyButton motion.
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

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onTap != null;
    final bg = !isEnabled
        ? AppColors.panel2
        : (_pressed ? widget.pressedColor : widget.color);

    final glow = isEnabled && _pressed
        ? AppShadows.softGlow(widget.color)
        : const <BoxShadow>[];

    return SquishyButton(
      enabled: isEnabled,
      onTap: () {
        if (widget.haptics) HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.br16,
            boxShadow: [...AppShadows.buttonShadow, ...glow],
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                BouncyIcon(icon: widget.icon!, color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 10),
              ],
              Text(widget.label, style: AppTextStyles.button),
            ],
          ),
        ),
      ),
    );
  }
}
