import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_currency_text.dart';
import '../../../../shared/widgets/press_scale.dart';

/// Fixed/variable cost summary on Home, tappable through to the Budget tab.
class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.fixedTotal,
    required this.variableBudgetTotal,
    required this.variableSpentTotal,
    required this.currency,
    required this.onTap,
  });

  final double fixedTotal;
  final double variableBudgetTotal;
  final double variableSpentTotal;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PressScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly costs', style: Theme.of(context).textTheme.titleLarge),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 12),
              _Row(
                label: 'Fixed',
                child: AnimatedCurrencyText(
                  amount: fixedTotal,
                  currency: currency,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 6),
              _Row(
                label: 'Variable (spent / budget)',
                child: AnimatedCurrencyRatioText(
                  numerator: variableSpentTotal,
                  denominator: variableBudgetTotal,
                  currency: currency,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 2),
        child,
      ],
    );
  }
}
