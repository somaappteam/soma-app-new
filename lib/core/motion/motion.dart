// lib/core/motion/motion.dart
import 'package:flutter/animation.dart';

/// Centralized motion tokens to keep the whole app feeling consistent (Unity-like).
class AppMotion {
  // ---------- Durations ----------
  static const Duration tapDown = Duration(milliseconds: 90);
  static const Duration tapUp = Duration(milliseconds: 180);

  static const Duration micro = Duration(milliseconds: 220);
  static const Duration page = Duration(milliseconds: 380);
  static const Duration sheet = Duration(milliseconds: 320);

  static const Duration shake = Duration(milliseconds: 260);
  static const Duration pulse = Duration(milliseconds: 200);

  // ---------- Curves ----------
  static const Curve enter = Curves.fastOutSlowIn;
  static const Curve microCurve = Curves.easeOutCubic;

  /// Great for button release "bounce". Use sparingly.
  static const Curve bounceOut = Curves.easeOutBack;

  /// Use for subtle UI transitions (opacity/position).
  static const Curve smooth = Curves.easeOutCubic;

  // ---------- Common scales ----------
  static const double pressScale = 0.97;
  static const double enterScaleFrom = 0.98;
}
