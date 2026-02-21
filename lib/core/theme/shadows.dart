// lib/core/theme/shadows.dart
import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized shadow recipes.
/// Unity-like UI often uses soft, layered shadows to create depth.
class AppShadows {
  /// Standard panel/card shadow.
  static const List<BoxShadow> panelShadow = [
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  /// Stronger shadow for primary interactive elements.
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x80000000), // 50% black
      blurRadius: 22,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  /// Soft inner glow (optional) to mimic "rim light".
  static List<BoxShadow> softGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.20),
      blurRadius: 22,
      spreadRadius: 1,
      offset: const Offset(0, 0),
    ),
  ];

  /// Subtle outline stroke via shadow trick (optional).
  static const List<BoxShadow> subtleOutline = [
    BoxShadow(
      color: Color(0x332C3A6E), // matches panelBorder vibe
      blurRadius: 0,
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  /// Dim overlay shadow for modals/sheets (not a box shadow but convenient token).
  static const Color modalOverlay = AppColors.overlay;
}
