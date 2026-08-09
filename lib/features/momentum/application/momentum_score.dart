import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/budget_config.dart';
import '../../../shared/models/savings_account.dart';
import '../../../shared/models/transaction_type.dart';
import '../../budget/application/budget_calculations.dart';
import '../../transactions/application/transaction_aggregates.dart';
import 'momentum_tier.dart';

/// The 5 weighted components behind a Momentum score (0-100), each capped
/// at its own max — see [calculateMomentum] for how each is derived.
class MomentumBreakdown {
  const MomentumBreakdown({
    required this.savingsRate,
    required this.streak,
    required this.debtTrend,
    required this.emergencyFund,
    required this.investmentRatio,
  });

  /// 0-30.
  final double savingsRate;

  /// 0-20.
  final double streak;

  /// 0-20.
  final double debtTrend;

  /// 0-15.
  final double emergencyFund;

  /// 0-15.
  final double investmentRatio;

  /// Sum of all 5 components, capped at 100 (the individual caps already
  /// sum to exactly 100, so this only guards against floating-point
  /// overshoot).
  double get total => (savingsRate + streak + debtTrend + emergencyFund + investmentRatio).clamp(0, 100);

  MomentumTier get tier => MomentumTier.forScore(total);
}

/// Computes the Momentum score from data the app already tracks: the
/// transaction ledger, the user's savings accounts (for the cash/invested
/// split), and their budget (for income and fixed costs). Pure and
/// side-effect free — same pattern as [MomentumTier], so it's unit
/// testable without Firestore or Riverpod in the loop.
MomentumBreakdown calculateMomentum({
  required List<AppTransaction> transactions,
  required List<SavingsAccount> accounts,
  required BudgetConfig budget,
  required DateTime now,
}) {
  return MomentumBreakdown(
    savingsRate: _savingsRateScore(transactions: transactions, budget: budget, now: now),
    streak: _streakScore(transactions: transactions, now: now),
    debtTrend: _debtTrendScore(transactions: transactions, now: now),
    emergencyFund: _emergencyFundScore(transactions: transactions, accounts: accounts, budget: budget, now: now),
    investmentRatio: _investmentRatioScore(transactions: transactions, accounts: accounts),
  );
}

/// Savings rate (0-30 pts): this month's Savings — Net Income (income
/// minus [totalMonthlyExpenses]) minus liability payments (debt_payment
/// transactions this month) — divided by income, floored at 0 if
/// negative. A 20%+ savings rate earns full points.
double _savingsRateScore({
  required List<AppTransaction> transactions,
  required BudgetConfig budget,
  required DateTime now,
}) {
  final income = budget.monthlyIncome;
  if (income <= 0) return 0;

  final window = currentMonthWindow(now);
  final expenses = totalMonthlyExpenses(budget, transactions, now);
  final liabilityPayments = totalForType(
    transactions,
    TransactionType.debtPayment,
    from: window.start,
    to: window.end,
  );
  final savings = income - expenses - liabilityPayments;
  final rate = savings <= 0 ? 0.0 : savings / income;
  return (rate / 0.20).clamp(0, 1) * 30;
}

/// Streak (0-20 pts): consecutive months (most recent backward) where
/// total savings increased OR total debt decreased vs. the prior month.
/// There's no stored monthly net-worth snapshot to read, so this
/// resamples the transaction ledger into month-end cumulative
/// savings/debt totals itself.
double _streakScore({required List<AppTransaction> transactions, required DateTime now}) {
  final months = _monthlySavingsDebtSeries(transactions, now);
  if (months.length < 2) return 0;

  var streak = 0;
  for (var i = months.length - 1; i >= 1; i--) {
    final curr = months[i];
    final prev = months[i - 1];
    final improved = curr.savings > prev.savings || curr.debt < prev.debt;
    if (!improved) break;
    streak++;
  }
  return (streak / 6).clamp(0, 1) * 20;
}

/// Debt trend (0-20 pts): if total debt decreased this month vs. last,
/// min(percent decrease / 0.10, 1) * 20 — 10%+ monthly reduction earns
/// full points. Flat or increased debt scores 0 (never negative).
double _debtTrendScore({required List<AppTransaction> transactions, required DateTime now}) {
  final months = _monthlySavingsDebtSeries(transactions, now);
  if (months.length < 2) return 0;

  final curr = months.last.debt;
  final prev = months[months.length - 2].debt;
  if (prev <= 0 || curr >= prev) return 0;

  final percentDecrease = (prev - curr) / prev;
  return (percentDecrease / 0.10).clamp(0, 1) * 20;
}

/// Emergency fund (0-15 pts): cash-only savings (investments aren't
/// instantly accessible, so they don't count) divided by this month's
/// expense run-rate = months covered. min(monthsCovered / 6, 1) * 15.
double _emergencyFundScore({
  required List<AppTransaction> transactions,
  required List<SavingsAccount> accounts,
  required BudgetConfig budget,
  required DateTime now,
}) {
  final expenses = totalMonthlyExpenses(budget, transactions, now);
  if (expenses <= 0) return 0;

  final cash = totalCashSavings(transactions, accounts);
  final monthsCovered = cash <= 0 ? 0.0 : cash / expenses;
  return (monthsCovered / 6).clamp(0, 1) * 15;
}

/// Investment ratio (0-15 pts): invested savings as a share of all
/// liquid savings (invested + cash). min(ratio / 0.30, 1) * 15 — 30%+
/// invested earns full points.
double _investmentRatioScore({
  required List<AppTransaction> transactions,
  required List<SavingsAccount> accounts,
}) {
  final invested = totalInvestedSavings(transactions, accounts);
  final cash = totalCashSavings(transactions, accounts);
  final total = invested + cash;
  if (total <= 0) return 0;

  final ratio = invested / total;
  return (ratio / 0.30).clamp(0, 1) * 15;
}

typedef _MonthlyTotals = ({double savings, double debt});

/// One entry per calendar month from the earliest savings/debt
/// transaction through [now]'s month, each holding the cumulative
/// savings and debt totals as of that month's end (or as of [now] for
/// the current, still-open month).
List<_MonthlyTotals> _monthlySavingsDebtSeries(List<AppTransaction> transactions, DateTime now) {
  final relevant = transactions
      .where((t) => t.type.kind == TransactionKind.savings || t.type.kind == TransactionKind.debt)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  if (relevant.isEmpty) return const [];

  final lastMonth = DateTime(now.year, now.month);
  var month = DateTime(relevant.first.date.year, relevant.first.date.month);

  final series = <_MonthlyTotals>[];
  var savings = 0.0;
  var debt = 0.0;
  var index = 0;
  while (!month.isAfter(lastMonth)) {
    final monthEnd = DateTime(month.year, month.month + 1);
    while (index < relevant.length && relevant[index].date.isBefore(monthEnd)) {
      final txn = relevant[index];
      final delta = txn.type.isIncrease ? txn.amount : -txn.amount;
      if (txn.type.kind == TransactionKind.savings) {
        savings += delta;
      } else {
        debt += delta;
      }
      index++;
    }
    series.add((savings: savings, debt: debt));
    month = DateTime(month.year, month.month + 1);
  }
  return series;
}
