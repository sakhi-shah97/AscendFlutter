import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../accounts/application/savings_account_migration.dart';
import '../../auth/application/auth_providers.dart';
import '../../budget/application/budget_calculations.dart';
import '../../budget/application/budget_providers.dart';
import '../../momentum/application/momentum_providers.dart';
import '../../momentum/presentation/widgets/momentum_hero.dart';
import '../../rank/application/net_worth_provider.dart';
import '../../transactions/application/transaction_aggregates.dart';
import '../../transactions/application/transaction_providers.dart';
import '../application/net_worth_projection.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/level_banner_strip.dart';
import 'widgets/net_worth_chart.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/savings_debt_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final budgetAsync = ref.watch(budgetProvider);

    if (transactionsAsync.isLoading && !transactionsAsync.hasValue) {
      return const _HomeLoading();
    }
    if (transactionsAsync.hasError && !transactionsAsync.hasValue) {
      return const _HomeError();
    }

    // Fire-and-forget: ensures a default cash savings account exists (and
    // any pre-accounts savings history is linked to it) before Momentum
    // needs the cash/invested split.
    ref.watch(savingsAccountMigrationProvider);

    final user = ref.watch(authStateChangesProvider).value;
    final netWorth = ref.watch(netWorthProvider);
    final momentum = ref.watch(momentumProvider);
    final transactions = transactionsAsync.value ?? const [];
    final budget = budgetAsync.value;
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
            DashboardStatStrip(children: const [NetLevelPill()]),
            const SizedBox(height: 12),
            MomentumHero(breakdown: momentum, netWorth: netWorth, currency: currency),
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
              )
            else if (budgetAsync.hasError)
              const _InlineErrorCard(message: "Couldn't load your budget.")
            else
              const _SectionLoadingCard(),
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

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ascend')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ascend')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "Couldn't load your dashboard. Check your connection and try again.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

/// A stand-in for [BudgetSummaryCard] while the budget doc is still loading.
class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
