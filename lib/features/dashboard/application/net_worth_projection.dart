import '../../transactions/application/transaction_aggregates.dart';

/// A short linear projection of net worth beyond the actual history, based
/// on the average daily rate of change between the first and last
/// historical points. Deliberately simple (not a forecasting model) — just
/// enough for the Home chart to show "if this trend continues," not a
/// financial prediction.
///
/// Returns one point per month for [projectionMonths] months after the
/// later of the last historical point or [asOf]. Empty if there isn't
/// enough history (fewer than 2 points, or they land on the same day) to
/// compute a trend.
List<NetWorthPoint> projectNetWorth(
  List<NetWorthPoint> history, {
  required DateTime asOf,
  int projectionMonths = 3,
}) {
  if (history.length < 2) return const [];

  final first = history.first;
  final last = history.last;
  final elapsedDays = last.date.difference(first.date).inDays;
  if (elapsedDays <= 0) return const [];

  final dailyRate = (last.netWorth - first.netWorth) / elapsedDays;
  final start = last.date.isAfter(asOf) ? last.date : asOf;

  final points = <NetWorthPoint>[];
  for (var month = 1; month <= projectionMonths; month++) {
    final date = DateTime(start.year, start.month + month, start.day);
    final daysFromLast = date.difference(last.date).inDays;
    points.add((date: date, netWorth: last.netWorth + dailyRate * daysFromLast));
  }
  return points;
}
