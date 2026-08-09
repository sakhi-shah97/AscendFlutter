import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../transactions/application/transaction_aggregates.dart';

/// Actual net worth history (solid) with a short trend projection (dashed)
/// bridging from the last real point.
class NetWorthChart extends StatelessWidget {
  const NetWorthChart({super.key, required this.history, required this.projection});

  final List<NetWorthPoint> history;
  final List<NetWorthPoint> projection;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Log a savings or debt transaction to start your net worth history.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final origin = history.first.date;
    double x(DateTime date) => date.difference(origin).inDays.toDouble();

    final actualSpots = [for (final point in history) FlSpot(x(point.date), point.netWorth)];
    final bridge = history.last;
    final projectedSpots = [
      FlSpot(x(bridge.date), bridge.netWorth),
      for (final point in projection) FlSpot(x(point.date), point.netWorth),
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              color: AppColors.goldHigh,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.goldHigh.withValues(alpha: 0.12),
              ),
            ),
            if (projectedSpots.length > 1)
              LineChartBarData(
                spots: projectedSpots,
                isCurved: true,
                color: AppColors.textMuted,
                barWidth: 2,
                dashArray: const [6, 4],
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}
