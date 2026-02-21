// lib/core/theme/radii.dart
import 'package:flutter/widgets.dart';

/// Centralized corner radius tokens.
/// Keep radii consistent across all panels/buttons to maintain the "game UI" look.
class AppRadii {
  // Base radii (use these most often)
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;

  // Common BorderRadius presets
  static const BorderRadius br12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius br24 = BorderRadius.all(Radius.circular(r24));

  // Pills (chips, small badges)
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
