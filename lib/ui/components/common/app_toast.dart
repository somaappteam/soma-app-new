// lib/ui/components/common/app_toast.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';

enum ToastType { success, error, info }

class AppToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, ToastType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, ToastType.info);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void _show(BuildContext context, String message, ToastType type) {
    hide();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => _ToastView(message: message, type: type, onClose: hide),
    );

    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(const Duration(milliseconds: 2200), hide);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String message;
  final ToastType type;
  final VoidCallback onClose;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.micro,
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.danger;
      case ToastType.info:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final fade = CurvedAnimation(parent: _ctrl, curve: AppMotion.smooth);
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(fade);

    return Positioned(
      top: topPadding + AppSpacing.s12,
      left: AppSpacing.s16,
      right: AppSpacing.s16,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: AppRadii.br16,
                border: Border.all(color: _accent.withOpacity(0.35)),
                boxShadow: [
                  ...AppShadows.panelShadow,
                  ...AppShadows.softGlow(_accent),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: _accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
