import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_currency_text.dart';

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
            _Legend(color: AppColors.jade, label: 'Savings', amount: savings, currency: currency),
            _Legend(color: AppColors.brick, label: 'Debt', amount: debt, currency: currency),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.amount, required this.currency});

  final Color color;
  final String label;
  final double amount;
  final String currency;

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
        AnimatedCurrencyText(
          amount: amount,
          currency: currency,
          style: AppTypography.numeric(size: 14, color: color),
        ),
      ],
    );
  }
}
