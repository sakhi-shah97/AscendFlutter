import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/budget_config.dart';
import '../../../shared/models/transaction_type.dart';
import '../../transactions/application/transaction_aggregates.dart';

/// Monthly income minus fixed costs (the known recurring commitment) minus
/// what's actually been spent on variable expenses so far this month —
/// i.e. how much of this month's income is still uncommitted.
double freeCashRemaining(BudgetConfig budget, List<AppTransaction> transactions, DateTime now) {
  final window = currentMonthWindow(now);
  final variableSpend = totalForType(
    transactions,
    TransactionType.variableExpense,
    from: window.start,
    to: window.end,
  );
  return budget.monthlyIncome - budget.fixedCostsTotal - variableSpend;
}

/// Fixed costs plus what's actually been spent on variable expenses so
/// far this calendar month — the real, lived-in expense figure (as
/// opposed to [BudgetConfig.variableBudgetTotal], which is only the plan).
/// Used by the Momentum score's savings-rate and emergency-fund
/// components.
double totalMonthlyExpenses(BudgetConfig budget, List<AppTransaction> transactions, DateTime now) {
  final window = currentMonthWindow(now);
  final variableSpend = totalForType(
    transactions,
    TransactionType.variableExpense,
    from: window.start,
    to: window.end,
  );
  return budget.fixedCostsTotal + variableSpend;
}

/// Category → spend for variable expenses in the current calendar month,
/// for the Budget tab's spend chart.
Map<String, double> variableSpendThisMonth(List<AppTransaction> transactions, DateTime now) {
  final window = currentMonthWindow(now);
  return categorySpend(
    transactions,
    type: TransactionType.variableExpense,
    from: window.start,
    to: window.end,
  );
}
