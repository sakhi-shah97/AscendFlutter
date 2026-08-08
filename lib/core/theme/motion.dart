import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  /// Overshoot spring feel — badges, tab switches, rank cards.
  static const Curve springOvershoot = Curves.elasticOut;
  static const Duration springDuration = Duration(milliseconds: 380);

  /// Flat, calm motion — ordinary content: lists, sheets, page transitions.
  static const Curve standard = Curves.easeOutCubic;
  static const Duration standardDuration = Duration(milliseconds: 250);

  static const Duration numberTween = Duration(milliseconds: 600);
  static const Duration rankUpDuration = Duration(milliseconds: 900);

  static const double pressScale = 0.96;
  static const Duration pressDuration = Duration(milliseconds: 120);
}