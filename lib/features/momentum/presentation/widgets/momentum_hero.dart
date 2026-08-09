import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_currency_text.dart';
import '../../application/momentum_score.dart';
import '../../application/momentum_tier.dart';

/// Light text tones for the hero's dark green gradient — distinct from
/// [AppColors.text] (authored for the cream background) since this card
/// is dark for most of its height.
const _creamText = Color(0xFFF6F0DE);
const _creamMuted = Color(0xB3F6F0DE);

/// Fixed ring gradient (not tier-colored — the ring is the same visual
/// signature at every tier).
const _ringStart = Color(0xFF4F7A54);
const _ringEnd = Color(0xFFA8D492);

/// The Home dashboard's primary hero: current Momentum score, tier, and
/// its 5-factor breakdown. Owns all of the card's animation (ring fill,
/// ambient glow/sparkle, and the tier-up burst) the same way
/// [HexagonRankBadge] owns the rank badge's — this widget is pure
/// display, driven by props from a watching parent, not a
/// [ConsumerWidget] itself.
class MomentumHero extends StatefulWidget {
  const MomentumHero({super.key, required this.breakdown, required this.netWorth, required this.currency});

  final MomentumBreakdown breakdown;
  final double netWorth;
  final String currency;

  @override
  State<MomentumHero> createState() => _MomentumHeroState();
}

class _MomentumHeroState extends State<MomentumHero> with TickerProviderStateMixin {
  late final AnimationController _ring =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _ambient =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  late Animation<double> _scoreAnimation;
  late MomentumTier _tier;

  @override
  void initState() {
    super.initState();
    _tier = widget.breakdown.tier;
    _scoreAnimation = Tween<double>(begin: 0, end: widget.breakdown.total)
        .animate(CurvedAnimation(parent: _ring, curve: Curves.easeOutCubic));
    _ring.forward();
  }

  @override
  void didUpdateWidget(covariant MomentumHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breakdown.total != widget.breakdown.total) {
      _scoreAnimation = Tween<double>(begin: 0, end: widget.breakdown.total)
          .animate(CurvedAnimation(parent: _ring, curve: Curves.easeOutCubic));
      _ring.forward(from: 0);
    }

    final newTier = widget.breakdown.tier;
    if (_tierIndex(newTier) > _tierIndex(_tier)) {
      _burst.forward(from: 0);
    }
    _tier = newTier;
  }

  int _tierIndex(MomentumTier tier) => MomentumTier.values.indexOf(tier);

  @override
  void dispose() {
    _ring.dispose();
    _ambient.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.breakdown.tier;
    final next = MomentumTier.next(tier);
    final ptsToNext = next == null ? null : (next.minScore - widget.breakdown.total).ceil();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF213B27), Color(0xFF2F4A34), AppColors.bg],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.gold.withValues(alpha: 0.20), AppColors.gold.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCurrencyText(
                    amount: widget.netWorth,
                    currency: widget.currency,
                    style: AppTypography.numeric(size: 14, color: _creamMuted),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(begin: tier.color, end: tier.color),
                        duration: const Duration(milliseconds: 450),
                        builder: (context, color, child) =>
                            CustomPaint(size: const Size(34, 34), painter: _LeafPainter(color: color ?? tier.color)),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: AnimatedBuilder(
                          animation: _burst,
                          builder: (context, child) => Transform.scale(
                            scale: _tierPopScale(_burst.value),
                            alignment: Alignment.centerLeft,
                            child: child,
                          ),
                          child: Text(
                            tier.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _creamText),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _MomentumRing(
                      scoreAnimation: _scoreAnimation,
                      ambient: _ambient,
                      burst: _burst,
                      tierColors: _burstColors(tier),
                      size: 168,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      next == null ? "You've reached the top tier" : '$ptsToNext pts to ${next.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _creamMuted),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _BreakdownChip(label: 'Savings rate', value: widget.breakdown.savingsRate, max: 30),
                      _BreakdownChip(label: 'Streak', value: widget.breakdown.streak, max: 20),
                      _BreakdownChip(label: 'Debt trend', value: widget.breakdown.debtTrend, max: 20),
                      _BreakdownChip(label: 'Emergency fund', value: widget.breakdown.emergencyFund, max: 15),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _TierLadder(current: tier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _burstColors(MomentumTier tier) => [tier.color, _ringEnd, _ringStart, _creamText];
}

/// Quick scale-pop with an overshoot then settle, played once across a
/// 0-to-1 burst controller: rises to 1.22x by 35% through the burst, then
/// eases back to 1.0 by the end.
double _tierPopScale(double t) {
  const peak = 0.35;
  if (t <= 0) return 1.0;
  if (t < peak) return 1.0 + 0.22 * Curves.easeOut.transform(t / peak);
  if (t < 1.0) return 1.0 + 0.22 * (1 - Curves.easeInOut.transform((t - peak) / (1 - peak)));
  return 1.0;
}

class _MomentumRing extends StatelessWidget {
  const _MomentumRing({
    required this.scoreAnimation,
    required this.ambient,
    required this.burst,
    required this.tierColors,
    required this.size,
  });

  final Animation<double> scoreAnimation;
  final Animation<double> ambient;
  final Animation<double> burst;
  final List<Color> tierColors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([scoreAnimation, ambient, burst]),
        builder: (context, child) {
          final score = scoreAnimation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.86,
                height: size * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ringEnd.withValues(alpha: 0.12 + 0.13 * ambient.value),
                      blurRadius: 26 + 18 * ambient.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              CustomPaint(size: Size(size, size), painter: _RingPainter(progress: (score / 100).clamp(0, 1))),
              CustomPaint(size: Size(size, size), painter: _SparklesPainter(t: ambient.value)),
              CustomPaint(
                size: Size(size, size),
                painter: _BurstParticlesPainter(t: burst.value, colors: tierColors),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.round().toString(),
                    style: AppTypography.numeric(size: 40, color: _creamText),
                  ),
                  Text('of 100', style: TextStyle(color: _creamMuted, fontSize: 12)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;
  static const _strokeWidth = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - _strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;
    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    final gradient = ui.Gradient.sweep(
      center,
      [_ringStart, _ringEnd],
      const [0.0, 1.0],
      TileMode.clamp,
      startAngle,
      startAngle + 2 * math.pi,
    );
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

/// 3 small dots twinkling around the ring, independent of the score or
/// any user action — purely ambient.
class _SparklesPainter extends CustomPainter {
  _SparklesPainter({required this.t});

  final double t;

  static const _dots = [
    _Sparkle(0.15, 0.86, 0.0),
    _Sparkle(0.88, 0.28, 0.35),
    _Sparkle(0.30, 0.10, 0.65),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in _dots) {
      final local = (t + dot.phase) % 1.0;
      final opacity = math.sin(math.pi * local).clamp(0.0, 1.0) * 0.8;
      canvas.drawCircle(
        Offset(dot.dx * size.width, dot.dy * size.height),
        2.4,
        Paint()..color = _creamText.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => oldDelegate.t != t;
}

class _Sparkle {
  const _Sparkle(this.dx, this.dy, this.phase);
  final double dx;
  final double dy;
  final double phase;
}

/// One-shot 16-particle burst fired from the ring's center on a real
/// tier-up, fading out over the ~900ms burst controller.
class _BurstParticlesPainter extends CustomPainter {
  _BurstParticlesPainter({required this.t, required this.colors});

  final double t;
  final List<Color> colors;
  static const _particleCount = 16;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOut.transform(t);
    final opacity = (1 - t).clamp(0.0, 1.0);

    for (var i = 0; i < _particleCount; i++) {
      final angle = i * (2 * math.pi / _particleCount);
      final dir = Offset(math.cos(angle), math.sin(angle));
      final dist = 12 + 78 * eased;
      final pos = center + dir * dist;
      final radius = 3.2 * (1 - t * 0.5);
      canvas.drawCircle(pos, radius, Paint()..color = colors[i % colors.length].withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _BurstParticlesPainter oldDelegate) => oldDelegate.t != t;
}

/// A simple leaf silhouette (two mirrored curves meeting at tip and
/// base, plus a center vein) that fills with the current tier's color.
class _LeafPainter extends CustomPainter {
  _LeafPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..quadraticBezierTo(w * 0.98, h * 0.18, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.02, h * 0.18, w * 0.5, h * 0.04)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.16),
      Offset(w * 0.5, h * 0.86),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => oldDelegate.color != color;
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({required this.label, required this.value, required this.max});

  final String label;
  final double value;
  final double max;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final dotColor = Color.lerp(_creamMuted.withValues(alpha: 0.4), _ringEnd, fraction)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _creamText, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// All 7 tiers as a segmented strip, the current one taller and full
/// brightness, the rest dimmed.
class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.current});

  final MomentumTier current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final tier in MomentumTier.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Container(
                    height: tier == current ? 8 : 5,
                    decoration: BoxDecoration(
                      color: tier == current ? tier.color : tier.color.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tier.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      color: tier == current ? _creamText : _creamMuted,
                      fontWeight: tier == current ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
