import 'package:flutter/material.dart';

import '../../core/theme/motion.dart';
import '../../core/utils/currency.dart';

/// A currency value that tweens to its new value instead of jump-cutting
/// whenever [amount] changes. Renders the correct value immediately on
/// first build (begin == end on mount), then animates smoothly on every
/// value change after that.
class AnimatedCurrencyText extends StatelessWidget {
  const AnimatedCurrencyText({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.prefix = '',
    this.showMinusSign = false,
  });

  /// The raw amount to display. If [showMinusSign] is true, a negative
  /// amount is rendered as its absolute value with a leading minus.
  final double amount;
  final String currency;
  final TextStyle? style;

  /// Fixed text (e.g. a transaction's +/− sign) shown before the number.
  final String prefix;
  final bool showMinusSign;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: amount, end: amount),
      duration: AppMotion.numberTween,
      curve: AppMotion.standard,
      builder: (context, value, child) {
        final sign = showMinusSign && value < 0 ? '−' : '';
        return Text('$sign$prefix${formatCurrency(value.abs(), currency)}', style: style);
      },
    );
  }
}

/// Two currency values tweening together into a single "spent / budget"
/// style string, kept as one [Text] widget so both numbers stay animated
/// in lockstep.
class AnimatedCurrencyRatioText extends StatelessWidget {
  const AnimatedCurrencyRatioText({
    super.key,
    required this.numerator,
    required this.denominator,
    required this.currency,
    this.style,
  });

  final double numerator;
  final double denominator;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: numerator, end: numerator),
      duration: AppMotion.numberTween,
      curve: AppMotion.standard,
      builder: (context, numeratorValue, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: denominator, end: denominator),
          duration: AppMotion.numberTween,
          curve: AppMotion.standard,
          builder: (context, denominatorValue, child) {
            return Text(
              '${formatCurrency(numeratorValue, currency)} / ${formatCurrency(denominatorValue, currency)}',
              style: style,
            );
          },
        );
      },
    );
  }
}
