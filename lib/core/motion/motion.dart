import 'package:flutter/animation.dart';

class AppMotion {
  static const Duration tapDown = Duration(milliseconds: 80);
  static const Duration tapUp = Duration(milliseconds: 220);

  static const Duration micro = Duration(milliseconds: 260);
  static const Duration page = Duration(milliseconds: 460);
  static const Duration sheet = Duration(milliseconds: 360);

  static const Duration snappy = Duration(milliseconds: 180);
  static const Duration gentle = Duration(milliseconds: 320);

  static const Duration shake = Duration(milliseconds: 260);
  static const Duration pulse = Duration(milliseconds: 260);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve microCurve = Curves.easeOutQuart;
  static const Curve bounceOut = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;

  static const double pressScale = 0.965;
  static const double enterScaleFrom = 0.975;
}
