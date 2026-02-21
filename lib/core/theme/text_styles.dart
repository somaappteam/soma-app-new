// lib/core/theme/text_styles.dart
import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized text styles.
/// Keep a tight set of styles so the UI stays consistent (Unity-like).
class AppTextStyles {
  // Base font family: you can set this in ThemeData later if desired.
  // For now, styles use default font with tuned weights/sizes.

  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textMuted,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle numberBig = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );
}
