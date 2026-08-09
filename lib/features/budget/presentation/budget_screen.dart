import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/budget_config.dart';
import '../../../shared/models/cost_item.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../../shared/widgets/animated_currency_text.dart';
import '../../../shared/widgets/press_scale.dart';
import '../../transactions/application/transaction_providers.dart';
import '../application/budget_calculations.dart';
import '../application/budget_providers.dart';
import 'widgets/category_spend_chart.dart';
import 'widgets/cost_list_section.dart';
import 'widgets/income_form_dialog.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: SafeArea(
        child: switch ((budgetAsync, transactionsAsync)) {
          (AsyncData(:final value), AsyncData(value: final transactions)) => _BudgetBody(
              budget: value,
              transactions: transactions,
            ),
          (AsyncError(), _) || (_, AsyncError()) => const _ErrorState(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _BudgetBody extends ConsumerWidget {
  const _BudgetBody({required this.budget, required this.transactions});

  final BudgetConfig budget;
  final List<AppTransaction> transactions;

  List<CostItem> _upsert(List<CostItem> items, CostItem item) {
    final index = items.indexWhere((c) => c.id == item.id);
    if (index == -1) return [...items, item];
    final copy = [...items];
    copy[index] = item;
    return copy;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final now = DateTime.now();
    final remaining = freeCashRemaining(budget, transactions, now);
    final spendByCategory = variableSpendThisMonth(transactions, now);

    Future<void> save(BudgetConfig next) {
      return ref.read(budgetControllerProvider).save(next);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _SummaryCard(
          income: budget.monthlyIncome,
          remaining: remaining,
          currency: currency,
          onEditIncome: () async {
            final newIncome = await showIncomeFormDialog(
              context,
              currentIncome: budget.monthlyIncome,
            );
            if (newIncome != null) await save(budget.copyWith(monthlyIncome: newIncome));
          },
        ),
        CostListSection(
          title: 'Fixed costs',
          items: budget.fixedCosts,
          amountLabel: 'Monthly amount',
          onSave: (item) => save(budget.copyWith(fixedCosts: _upsert(budget.fixedCosts, item))),
          onDelete: (item) => save(
            budget.copyWith(fixedCosts: budget.fixedCosts.where((c) => c.id != item.id).toList()),
          ),
        ),
        CostListSection(
          title: 'Variable costs',
          items: budget.variableCosts,
          amountLabel: 'Monthly budget',
          spentByCategory: spendByCategory,
          onSave: (item) =>
              save(budget.copyWith(variableCosts: _upsert(budget.variableCosts, item))),
          onDelete: (item) => save(
            budget.copyWith(
              variableCosts: budget.variableCosts.where((c) => c.id != item.id).toList(),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spend by category', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                CategorySpendChart(spendByCategory: spendByCategory, currency: currency),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.income,
    required this.remaining,
    required this.currency,
    required this.onEditIncome,
  });

  final double income;
  final double remaining;
  final String currency;
  final VoidCallback onEditIncome;

  @override
  Widget build(BuildContext context) {
    final isNegative = remaining < 0;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Free cash remaining', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            AnimatedCurrencyText(
              amount: remaining,
              currency: currency,
              showMinusSign: true,
              style: AppTypography.numeric(
                size: 32,
                color: isNegative ? AppColors.brick : AppColors.goldHigh,
              ),
            ),
            const SizedBox(height: 16),
            PressScale(
              onTap: onEditIncome,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly income', style: Theme.of(context).textTheme.bodyMedium),
                  Row(
                    children: [
                      AnimatedCurrencyText(
                        amount: income,
                        currency: currency,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          "Couldn't load your budget. Check your connection and try again.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
