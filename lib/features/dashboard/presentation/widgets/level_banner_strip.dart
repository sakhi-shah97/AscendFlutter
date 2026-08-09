import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency.dart';
import '../../../../shared/providers/user_profile_providers.dart';
import '../../../../shared/widgets/press_scale.dart';
import '../../../rank/application/net_worth_provider.dart';
import '../../../rank/application/rank_tier.dart';

/// A horizontally-scrollable row of small stat pills at the top of Home.
/// Currently holds just the Net Financial Level pill, but is built to
/// take more pills later without changing its own layout.
class DashboardStatStrip extends StatelessWidget {
  const DashboardStatStrip({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// The compact Net Financial Level pill: a small flat hexagon in the
/// current tier's color, the tier name, a thin progress line, and "X to
/// next level". Taps through to the full rank detail screen, same as the
/// old hero badge did.
class NetLevelPill extends ConsumerWidget {
  const NetLevelPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(netWorthProvider);
    final currency = ref.watch(currencyProvider);
    final tier = RankTier.forNetWorth(netWorth);
    final next = RankTier.next(tier);
    final floor = tier?.threshold ?? 0;
    final progress = next == null ? 1.0 : ((netWorth - floor) / (next.threshold - floor)).clamp(0, 1).toDouble();
    final color = tier?.color ?? AppColors.textMuted;

    return PressScale(
      onTap: () => context.push('/home/rank'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: const Size(28, 30.8), painter: _FlatHexagonPainter(color: color)),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier?.displayName ?? 'Unranked',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    width: 92,
                    height: 3,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surface2,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  next == null ? 'Max level' : '${formatCurrency(next.threshold - netWorth, currency)} to next level',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A flat, single-color hexagon — the small-scale sibling of
/// [HexagonRankBadge]'s faceted gem, used where the full animated
/// treatment would be too heavy (e.g. this banner pill).
class _FlatHexagonPainter extends CustomPainter {
  _FlatHexagonPainter({required this.color});

  final Color color;

  static const _designWidth = 200.0;
  static const _vertices = [
    Offset(100, 25),
    Offset(173.6, 67.5),
    Offset(173.6, 152.5),
    Offset(100, 195),
    Offset(26.4, 152.5),
    Offset(26.4, 67.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _designWidth;
    canvas.save();
    canvas.scale(scale);

    final path = Path()..addPolygon(_vertices, true);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Color.lerp(color, Colors.white, 0.45)!,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlatHexagonPainter oldDelegate) => oldDelegate.color != color;
}
