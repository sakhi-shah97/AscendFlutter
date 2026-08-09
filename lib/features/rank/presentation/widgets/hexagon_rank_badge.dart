import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/rank_tier.dart';

/// Shared [Hero] tag between the Home badge and [RankDetailScreen].
const rankBadgeHeroTag = 'rank-badge';

/// Design-space canvas the hexagon geometry below is authored in; painters
/// scale it to whatever pixel size the widget is actually given.
const _designWidth = 200.0;
const _designHeight = 220.0;
const _center = Offset(100, 110);

/// Outer vertices, in winding order starting at the top point. Facet [i] is
/// the triangle (center, vertices[i], vertices[i+1]) and is named after
/// vertices[i] — e.g. facet 0 ("top") spans from the top point to the
/// upper-right point.
const _vertices = [
  Offset(100, 25), // top
  Offset(173.6, 67.5), // upperRight
  Offset(173.6, 152.5), // lowerRight
  Offset(100, 195), // bottom
  Offset(26.4, 152.5), // lowerLeft
  Offset(26.4, 67.5), // upperLeft
];

/// Same lightness ladder used by [singleHueFacetGradients], reused here so
/// the light-throw glow/rays and burst particles land on the moment the
/// gem's own facets are brightest.
const _popPeak = 0.68;

/// The signature faceted-gem rank badge. Three animation layers share one
/// looping [AnimationController] so they stay perfectly in sync: a
/// continuous 3D tilt, a periodic "pop" scale bounce, and a light-throw
/// (glow + rays) timed to the pop's overshoot. A long-press fires a
/// separate one-shot burst (used for real rank-ups too, via
/// [didUpdateWidget]).
class HexagonRankBadge extends StatefulWidget {
  const HexagonRankBadge({super.key, required this.netWorth, this.size = 140, this.heroTag});

  /// Net Financial Level (total savings − total debt), in AED.
  final double netWorth;
  final double size;

  /// When set, wraps just the hexagon (not the label below it) in a [Hero]
  /// with this tag — used to fly it into [RankDetailScreen].
  final Object? heroTag;

  @override
  State<HexagonRankBadge> createState() => _HexagonRankBadgeState();
}

class _HexagonRankBadgeState extends State<HexagonRankBadge> with TickerProviderStateMixin {
  late final AnimationController _cycle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4500))..repeat();
  late final AnimationController _burst =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  AnimationController? _twinkle;

  RankTier? _tier;

  @override
  void initState() {
    super.initState();
    _tier = RankTier.forNetWorth(widget.netWorth);
    if (_tier?.group.hasTwinkle ?? false) {
      _twinkle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HexagonRankBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTier = RankTier.forNetWorth(widget.netWorth);
    if (_rankIndex(newTier) > _rankIndex(_tier)) {
      _burst.forward(from: 0);
    }
    _tier = newTier;

    final needsTwinkle = newTier?.group.hasTwinkle ?? false;
    final hasTwinkle = _twinkle != null;
    if (needsTwinkle != hasTwinkle) {
      setState(() {
        if (needsTwinkle) {
          _twinkle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
            ..repeat();
        } else {
          _twinkle!.dispose();
          _twinkle = null;
        }
      });
    }
  }

  int _rankIndex(RankTier? tier) => tier == null ? -1 : RankTier.all.indexOf(tier);

  @override
  void dispose() {
    _cycle.dispose();
    _burst.dispose();
    _twinkle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;
    final accent = tier?.group.color ?? AppColors.textMuted;
    final facetGradients = tier?.group.facetGradients ?? singleHueFacetGradients(AppColors.textMuted);
    final particleColors = [for (final facet in facetGradients) facet.first];

    final width = widget.size;
    final height = widget.size * (_designHeight / _designWidth);

    Widget hexagon = SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _burst.forward(from: 0),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _cycle,
              builder: (context, _) => CustomPaint(
                size: Size(width, height),
                painter: _GlowRaysPainter(color: accent, t: _cycle.value),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_cycle, _burst]),
              builder: (context, child) {
                final t = _cycle.value;
                final bt = _burst.value;
                final yAngle = 7 * math.sin(2 * math.pi * t) * math.pi / 180;
                final xAngle = -3 * math.sin(2 * math.pi * t) * math.pi / 180;
                final zAngle = _burstRotation(bt);
                final scale = _popScale(t) * (1 + _burstExtraScale(bt));

                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateX(xAngle)
                  ..rotateY(yAngle)
                  ..rotateZ(zAngle)
                  ..scaleByDouble(scale, scale, scale, 1);

                return Transform(
                  alignment: Alignment.center,
                  transform: transform,
                  child: child,
                );
              },
              child: CustomPaint(
                size: Size(width, height),
                painter: _HexagonPainter(
                  facetGradients: facetGradients,
                  strokeColor: Color.lerp(accent, Colors.white, 0.55)!,
                  sparkleColor: Color.lerp(accent, Colors.white, 0.7)!,
                ),
              ),
            ),
            if (_twinkle != null)
              AnimatedBuilder(
                animation: _twinkle!,
                builder: (context, _) => CustomPaint(
                  size: Size(width, height),
                  painter: _TwinkleDotsPainter(t: _twinkle!.value),
                ),
              ),
            AnimatedBuilder(
              animation: _burst,
              builder: (context, _) => CustomPaint(
                size: Size(width, height),
                painter: _BurstParticlesPainter(t: _burst.value, colors: particleColors),
              ),
            ),
          ],
        ),
      ),
    );

    final tag = widget.heroTag;
    if (tag != null) {
      hexagon = Hero(tag: tag, child: hexagon);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        hexagon,
        const SizedBox(height: 16),
        Text(
          tier?.displayName ?? 'Unranked',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: accent),
        ),
      ],
    );
  }
}

/// Piecewise pop-and-return scale: flat at 1.0 for the first 60% of the
/// cycle, then a quick overshoot to 1.12, a settle to 0.96, a correction to
/// 1.03, and an ease back to 1.0 by the end.
double _popScale(double t) {
  const stops = [0.0, 0.60, _popPeak, 0.80, 0.90, 1.00];
  const values = [1.0, 1.0, 1.12, 0.96, 1.03, 1.0];
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1] || i == stops.length - 2) {
      final span = stops[i + 1] - stops[i];
      final localT = span == 0 ? 0.0 : ((t - stops[i]) / span).clamp(0.0, 1.0);
      final curve = i == 1 ? Curves.easeOut : Curves.easeInOut;
      final eased = curve.transform(localT);
      return values[i] + (values[i + 1] - values[i]) * eased;
    }
  }
  return 1.0;
}

/// A decaying oscillation, zero at both ends of the burst — the "further"
/// scale boost on top of the ambient pop, and its slight rotational wobble.
double _burstExtraScale(double bt) => bt <= 0 ? 0.0 : 0.35 * (1 - bt) * math.sin(bt * math.pi * 3);

double _burstRotation(double bt) =>
    bt <= 0 ? 0.0 : (12 * math.pi / 180) * (1 - bt) * math.sin(bt * math.pi * 3);

class _HexagonPainter extends CustomPainter {
  _HexagonPainter({required this.facetGradients, required this.strokeColor, required this.sparkleColor});

  final List<List<Color>> facetGradients;
  final Color strokeColor;
  final Color sparkleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _designWidth;
    canvas.save();
    canvas.scale(scale);

    for (var i = 0; i < 6; i++) {
      final a = _vertices[i];
      final b = _vertices[(i + 1) % 6];
      final facetPath = Path()
        ..moveTo(_center.dx, _center.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close();
      final outerMid = Offset.lerp(a, b, 0.5)!;
      final paint = Paint()..shader = ui.Gradient.linear(_center, outerMid, facetGradients[i]);
      canvas.drawPath(facetPath, paint);
    }

    final outline = Path()..addPolygon(_vertices, true);
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = strokeColor,
    );

    // Specular highlight ellipse, sitting on the upper-left facet.
    final upperLeftMid = Offset.lerp(_vertices[5], _vertices[0], 0.5)!;
    final highlightCenter = Offset.lerp(_center, upperLeftMid, 0.5)!;
    canvas.save();
    canvas.translate(highlightCenter.dx, highlightCenter.dy);
    canvas.rotate(-0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 36, height: 16),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();

    // Diamond sparkle glyph, centered on top of everything.
    canvas.drawPath(_diamondPath(_center, 11, 7), Paint()..color = sparkleColor.withValues(alpha: 0.5));
    canvas.drawPath(
      _diamondPath(_center, 4, 2.5),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    canvas.restore();
  }

  Path _diamondPath(Offset center, double halfHeight, double halfWidth) {
    return Path()
      ..moveTo(center.dx, center.dy - halfHeight)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..lineTo(center.dx, center.dy + halfHeight)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor || !identical(oldDelegate.facetGradients, facetGradients);
}

/// Glow + radiating rays behind the hexagon, timed to flash at the pop's
/// overshoot moment ([_popPeak], 68% through the shared cycle) rather than
/// running on its own timeline.
class _GlowRaysPainter extends CustomPainter {
  _GlowRaysPainter({required this.color, required this.t});

  final Color color;
  final double t;

  static const _rayLengthsPx = [92.0, 104.0, 88.0, 112.0, 96.0, 108.0, 90.0, 115.0];
  static const _rampInEnd = _popPeak;
  static const _rampInStart = 0.60;
  static const _fadeOutEnd = _popPeak + 0.20;
  static const _rayWindow = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _designWidth;
    canvas.save();
    canvas.scale(scale);

    const lowOpacity = 0.22;
    const baseRadius = 72.0;

    double rampT;
    if (t < _rampInStart) {
      rampT = 0.0;
    } else if (t < _rampInEnd) {
      rampT = Curves.easeOut.transform((t - _rampInStart) / (_rampInEnd - _rampInStart));
    } else if (t < _fadeOutEnd) {
      rampT = 1 - Curves.easeIn.transform((t - _rampInEnd) / (_fadeOutEnd - _rampInEnd));
    } else {
      rampT = 0.0;
    }

    canvas.drawCircle(
      _center,
      baseRadius * (1 + 0.4 * rampT),
      Paint()
        ..color = color.withValues(alpha: lowOpacity + (1 - lowOpacity) * rampT)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    if (t >= _popPeak && t < _popPeak + _rayWindow) {
      final local = (t - _popPeak) / _rayWindow;
      final rayOpacity = 1 - local;
      final colorHsl = HSLColor.fromColor(color);
      final rayColor =
          colorHsl.withLightness(0.60).withSaturation((colorHsl.saturation * 1.15).clamp(0.0, 1.0)).toColor();
      const innerRadius = 92.0;
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final dir = Offset(math.cos(angle), math.sin(angle));
        final length = _rayLengthsPx[i] * local;
        final start = _center + dir * innerRadius;
        final end = start + dir * length;
        canvas.drawLine(
          start,
          end,
          Paint()
            ..color = rayColor.withValues(alpha: rayOpacity)
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlowRaysPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// Diamond tier only: four twinkling dots near the top facets, each fading
/// in and out on its own staggered phase within the shared 1.8s loop.
class _TwinkleDotsPainter extends CustomPainter {
  _TwinkleDotsPainter({required this.t});

  final double t;

  static const _dots = [
    _TwinkleDot(Offset(78, 44), Color(0xFFE8B84B), 0.0),
    _TwinkleDot(Offset(124, 39), Color(0xFFE896C0), 0.28),
    _TwinkleDot(Offset(141, 63), Color(0xFF6BC2C9), 0.55),
    _TwinkleDot(Offset(96, 29), Colors.white, 0.80),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _designWidth;
    canvas.save();
    canvas.scale(scale);
    for (final dot in _dots) {
      final local = (t + dot.phase) % 1.0;
      final opacity = math.sin(math.pi * local).clamp(0.0, 1.0) * 0.85;
      canvas.drawCircle(dot.offset, 3.2, Paint()..color = dot.color.withValues(alpha: opacity));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TwinkleDotsPainter oldDelegate) => oldDelegate.t != t;
}

class _TwinkleDot {
  const _TwinkleDot(this.offset, this.color, this.phase);
  final Offset offset;
  final Color color;
  final double phase;
}

/// One-shot burst particles, driven by the tap/rank-up [AnimationController]
/// (0 = idle, animates 0→1 once per trigger). Flies outward from center in
/// the tier's own facet colors and fades to nothing by t=1.
class _BurstParticlesPainter extends CustomPainter {
  _BurstParticlesPainter({required this.t, required this.colors});

  final double t;
  final List<Color> colors;

  static const _anglesDeg = [10.0, 55.0, 95.0, 140.0, 175.0, 220.0, 260.0, 300.0, 330.0, 30.0, 130.0, 250.0];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final scale = size.width / _designWidth;
    canvas.save();
    canvas.scale(scale);

    final eased = Curves.easeOut.transform(t);
    final opacity = (1 - t).clamp(0.0, 1.0);

    for (var i = 0; i < _anglesDeg.length; i++) {
      final angle = _anglesDeg[i] * math.pi / 180;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final dist = 20 + 95 * eased;
      final pos = _center + dir * dist;
      final radius = 3.5 * (1 - t * 0.5);
      canvas.drawCircle(pos, radius, Paint()..color = colors[i % colors.length].withValues(alpha: opacity));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BurstParticlesPainter oldDelegate) => oldDelegate.t != t;
}
