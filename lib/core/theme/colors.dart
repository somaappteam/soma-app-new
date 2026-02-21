// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

/// Centralized color tokens (Unity-like: soft gradient background + clean panels).
/// Keep this file as the single source of truth for colors.
class AppColors {
  // ---------- Background ----------
  static const Color bgTop = Color(0xFF0E1630); // deep navy
  static const Color bgMid = Color(0xFF101F45); // slightly brighter
  static const Color bgBottom = Color(0xFF0B1026); // deep

  // Optional glow blobs (used as blurred decorative circles)
  static const Color blob1 = Color(0xFF3C7DFF);
  static const Color blob2 = Color(0xFFFF4FD8);
  static const Color blob3 = Color(0xFF28E6B9);

  // ---------- Surfaces / Panels ----------
  static const Color panel = Color(0xFF151F3F); // card background
  static const Color panel2 = Color(0xFF101836); // deeper card background
  static const Color panelBorder = Color(
    0x332C3A6E,
  ); // subtle border (20% opacity)

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFFB7C3F3);
  static const Color textMuted = Color(0xFF7F8BC4);

  // ---------- Brand / Actions ----------
  static const Color primary = Color(0xFF3C7DFF);
  static const Color primaryPressed = Color(0xFF2B67E6);

  static const Color secondary = Color(0xFF8A5CFF);
  static const Color secondaryPressed = Color(0xFF7446EA);

  // ---------- States ----------
  static const Color success = Color(0xFF28E6B9);
  static const Color success2 = Color(0xFF19CFA6);

  static const Color danger = Color(0xFFFF4D6D);
  static const Color danger2 = Color(0xFFE43A59);

  static const Color warning = Color(0xFFFFC857);

  /// Alias for XP / score highlights (golden / amber)
  static const Color accent = Color(0xFFFFC857);

  // ---------- Misc ----------
  static const Color shadow = Color(0xCC000000); // for shadows (80% black)
  static const Color overlay = Color(0x99000000); // modal overlay (60% black)

  static const Color transparent = Colors.transparent;
}

/// Common gradients used across the app.
class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
  );

  /// Subtle panel shine (optional).
  static const LinearGradient panelSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Color(0x00FFFFFF), // transparent
    ],
  );
}
