// lib/ui/components/common/app_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Reusable "scene" wrapper that gives every screen the same Unity-like feel:
/// - gradient background
/// - floating blurred blobs for depth
/// - SafeArea + consistent padding
///
/// Use this for Home/Player/Result. Setup can also use it if you want.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.body, this.hud, this.bottom});

  final Widget body;
  final Widget? hud;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                if (hud != null) hud!,
                Expanded(child: body),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: const [
          _Blob(color: AppColors.blob1, top: -80, left: -50, size: 220),
          _Blob(color: AppColors.blob2, top: 180, right: -70, size: 260),
          _Blob(color: AppColors.blob3, bottom: -90, left: 40, size: 240),
          _SoftNoiseOverlay(),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
  });

  final Color color;
  final double? top, left, right, bottom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.22),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Optional subtle overlay to make gradients feel less "flat".
/// This is a cheap visual trick (not real noise) to add depth.
class _SoftNoiseOverlay extends StatelessWidget {
  const _SoftNoiseOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.transparent,
                Colors.black.withOpacity(0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
