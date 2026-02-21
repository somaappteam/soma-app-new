// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';

/// Optional ThemeData so default widgets match your UI style.
/// This isn't required, but it makes the app feel more consistent.
class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgBottom,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.panel,
        error: AppColors.danger,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.panelBorder,
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x333C7DFF),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
}
