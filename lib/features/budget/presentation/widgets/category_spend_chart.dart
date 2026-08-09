import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';

/// A pie chart + legend of variable expense spend by category, for the
/// current calendar month.
class CategorySpendChart extends StatelessWidget {
  const CategorySpendChart({super.key, required this.spendByCategory, required this.currency});

  final Map<String, double> spendByCategory;
  final String currency;

  static const _palette = <Color>[
    AppColors.gold,
    AppColors.jade,
    AppColors.brick,
    AppColors.goldHigh,
    AppColors.emerald,
    Color(0xFF6EC3E0),
    Color(0xFFB08D57),
  ];

  @override
  Widget build(BuildContext context) {
    if (spendByCategory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No variable spending logged this month yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final entries = spendByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 44,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: _palette[i % _palette.length],
                    title: '',
                    radius: 40,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entries[i].key, style: Theme.of(context).textTheme.bodyMedium),
                ),
                Text(formatCurrency(entries[i].value, currency), style: AppTypography.numeric(size: 13)),
                const SizedBox(width: 8),
                Text(
                  '${(entries[i].value / total * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
