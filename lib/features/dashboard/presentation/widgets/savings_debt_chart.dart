import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';

class SavingsDebtChart extends StatelessWidget {
  const SavingsDebtChart({
    super.key,
    required this.savings,
    required this.debt,
    required this.currency,
  });

  final double savings;
  final double debt;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final maxValue = [savings, debt, 1.0].reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              maxY: maxValue * 1.2,
              barTouchData: const BarTouchData(enabled: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: savings,
                      color: AppColors.jade,
                      width: 40,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: debt,
                      color: AppColors.brick,
                      width: 40,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Legend(color: AppColors.jade, label: 'Savings', value: formatCurrency(savings, currency)),
            _Legend(color: AppColors.brick, label: 'Debt', value: formatCurrency(debt, currency)),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.numeric(size: 14, color: color)),
      ],
    );
  }
}
