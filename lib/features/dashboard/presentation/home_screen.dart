import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../budget/application/budget_calculations.dart';
import '../../budget/application/budget_providers.dart';
import '../../rank/application/net_worth_provider.dart';
import '../../rank/presentation/widgets/hexagon_rank_badge.dart';
import '../../transactions/application/transaction_aggregates.dart';
import '../../transactions/application/transaction_providers.dart';
import '../application/net_worth_projection.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/net_worth_chart.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/savings_debt_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final netWorth = ref.watch(netWorthProvider);
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final budget = ref.watch(budgetProvider).value;
    final currency = ref.watch(currencyProvider);
    final displayName = user?.displayName;
    final greetingName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user?.email ?? 'ascender');

    final now = DateTime.now();
    final history = netWorthTrajectory(transactions);
    final projection = projectNetWorth(history, asOf: now);
    final variableSpend = variableSpendThisMonth(transactions, now).values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Ascend')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Welcome, $greetingName.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.text),
              ),
            ),
            Center(child: HexagonRankBadge(netWorth: netWorth)),
            const SizedBox(height: 8),
            _SectionCard(
              title: 'Net worth trajectory',
              child: NetWorthChart(history: history, projection: projection),
            ),
            _SectionCard(
              title: 'Savings vs. debt',
              child: SavingsDebtChart(
                savings: totalSavings(transactions),
                debt: totalDebt(transactions),
                currency: currency,
              ),
            ),
            if (budget != null)
              BudgetSummaryCard(
                fixedTotal: budget.fixedCostsTotal,
                variableBudgetTotal: budget.variableBudgetTotal,
                variableSpentTotal: variableSpend,
                currency: currency,
                onTap: () => context.go('/budget'),
              ),
            RecentActivityCard(
              transactions: transactions,
              onViewAll: () => context.go('/activity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
