import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/motion.dart';
import '../../application/rank_tier.dart';

/// The signature hexagon rank badge. Re-plays its spring/overshoot entrance
/// whenever the resolved tier changes (i.e. a rank-up), since it's keyed by
/// tier identity.
class HexagonRankBadge extends StatelessWidget {
  const HexagonRankBadge({super.key, required this.netWorth, this.size = 140});

  /// Net Financial Level (total savings − total debt), in AED.
  final double netWorth;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tier = RankTier.forNetWorth(netWorth);
    final color = tier?.color ?? AppColors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _HexagonPainter(color: color)),
        )
            .animate(key: ValueKey(tier?.displayName ?? 'unranked'))
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              duration: AppMotion.rankUpDuration,
              curve: AppMotion.springOvershoot,
            )
            .fadeIn(duration: AppMotion.standardDuration),
        const SizedBox(height: 16),
        Text(
          tier?.displayName ?? 'Unranked',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _HexagonPainter extends CustomPainter {
  _HexagonPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexagonPath(size);
    final center = Offset(size.width / 2, size.height / 2);

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.15)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
        stops: const [0, 0.6, 1],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Color.lerp(color, Colors.white, 0.4)!;
    canvas.drawPath(path, strokePaint);
  }

  Path _hexagonPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.94;
    for (var i = 0; i < 6; i++) {
      final angle = (-90 + i * 60) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) => oldDelegate.color != color;
}
