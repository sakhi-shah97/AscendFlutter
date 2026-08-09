import 'package:flutter/material.dart';

import '../../core/theme/motion.dart';

/// Wraps [child] in an [InkWell] whose press state also drives a subtle
/// scale-down, so tappable cards/tiles/rows feel physically pressed rather
/// than just showing a ripple. Drop-in replacement for a plain [InkWell].
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? AppMotion.pressScale : 1,
      duration: AppMotion.pressDuration,
      curve: Curves.easeOut,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.borderRadius,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        child: widget.child,
      ),
    );
  }
}
