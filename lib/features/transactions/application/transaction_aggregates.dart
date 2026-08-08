import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/transaction_type.dart';

/// A single point on the net worth trajectory chart.
typedef NetWorthPoint = ({DateTime date, double netWorth});

/// A half-open `[start, end)` date window, e.g. a calendar month.
typedef DateWindow = ({DateTime start, DateTime end});

double totalSavings(List<AppTransaction> transactions) =>
    _netForKind(transactions, TransactionKind.savings);

double totalDebt(List<AppTransaction> transactions) =>
    _netForKind(transactions, TransactionKind.debt);

/// Net Financial Level = total savings − total debt, matching [RankTier].
double netWorth(List<AppTransaction> transactions) =>
    totalSavings(transactions) - totalDebt(transactions);

double _netForKind(List<AppTransaction> transactions, TransactionKind kind) {
  var total = 0.0;
  for (final txn in transactions) {
    if (txn.type.kind != kind) continue;
    total += txn.type.isIncrease ? txn.amount : -txn.amount;
  }
  return total;
}

/// Sums transaction amounts of a single [type], optionally restricted to a
/// `[from, to)` window.
double totalForType(
  List<AppTransaction> transactions,
  TransactionType type, {
  DateTime? from,
  DateTime? to,
}) {
  var total = 0.0;
  for (final txn in transactions) {
    if (txn.type != type) continue;
    if (from != null && txn.date.isBefore(from)) continue;
    if (to != null && !txn.date.isBefore(to)) continue;
    total += txn.amount;
  }
  return total;
}

/// Groups transactions of a single [type] by category (defaulting to
/// "Other"), optionally restricted to a `[from, to)` window.
Map<String, double> categorySpend(
  List<AppTransaction> transactions, {
  required TransactionType type,
  DateTime? from,
  DateTime? to,
}) {
  final totals = <String, double>{};
  for (final txn in transactions) {
    if (txn.type != type) continue;
    if (from != null && txn.date.isBefore(from)) continue;
    if (to != null && !txn.date.isBefore(to)) continue;
    final key = (txn.category?.isNotEmpty ?? false) ? txn.category! : 'Other';
    totals[key] = (totals[key] ?? 0) + txn.amount;
  }
  return totals;
}

DateWindow currentMonthWindow(DateTime now) {
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  return (start: start, end: end);
}

/// The running (cumulative) net worth after each savings/debt transaction,
/// in chronological order — the "actual history" half of the Home net
/// worth trajectory chart.
List<NetWorthPoint> netWorthTrajectory(List<AppTransaction> transactions) {
  final relevant = transactions
      .where((t) => t.type.kind == TransactionKind.savings || t.type.kind == TransactionKind.debt)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final points = <NetWorthPoint>[];
  var savings = 0.0;
  var debt = 0.0;
  for (final txn in relevant) {
    final delta = txn.type.isIncrease ? txn.amount : -txn.amount;
    if (txn.type.kind == TransactionKind.savings) {
      savings += delta;
    } else {
      debt += delta;
    }
    points.add((date: txn.date, netWorth: savings - debt));
  }
  return points;
}
