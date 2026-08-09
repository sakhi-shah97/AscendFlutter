import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/dashboard/application/net_worth_projection.dart';

void main() {
  group('projectNetWorth', () {
    test('returns nothing with fewer than 2 history points', () {
      expect(projectNetWorth(const [], asOf: DateTime(2026, 1, 1)), isEmpty);
      expect(
        projectNetWorth(
          [(date: DateTime(2026, 1, 1), netWorth: 100.0)],
          asOf: DateTime(2026, 1, 1),
        ),
        isEmpty,
      );
    });

    test('returns nothing when all history points share the same day', () {
      final history = [
        (date: DateTime(2026, 1, 1), netWorth: 100.0),
        (date: DateTime(2026, 1, 1), netWorth: 200.0),
      ];
      expect(projectNetWorth(history, asOf: DateTime(2026, 1, 1)), isEmpty);
    });

    test('extrapolates the average daily rate forward monthly', () {
      // +1000 over 10 days = +100/day.
      final history = [
        (date: DateTime(2026, 1, 1), netWorth: 1000.0),
        (date: DateTime(2026, 1, 11), netWorth: 2000.0),
      ];
      final projection = projectNetWorth(
        history,
        asOf: DateTime(2026, 1, 11),
        projectionMonths: 2,
      );

      expect(projection, hasLength(2));
      expect(projection[0].date, DateTime(2026, 2, 11));
      expect(projection[0].netWorth, 2000 + 100 * 31);
      expect(projection[1].date, DateTime(2026, 3, 11));
    });

    test('starts from asOf when it is later than the last history point', () {
      final history = [
        (date: DateTime(2026, 1, 1), netWorth: 1000.0),
        (date: DateTime(2026, 1, 11), netWorth: 2000.0),
      ];
      final projection = projectNetWorth(
        history,
        asOf: DateTime(2026, 2, 1),
        projectionMonths: 1,
      );

      expect(projection.single.date, DateTime(2026, 3, 1));
    });

    test('a declining trend produces a declining projection', () {
      final history = [
        (date: DateTime(2026, 1, 1), netWorth: 5000.0),
        (date: DateTime(2026, 1, 11), netWorth: 4000.0),
      ];
      final projection = projectNetWorth(
        history,
        asOf: DateTime(2026, 1, 11),
        projectionMonths: 1,
      );
      expect(projection.single.netWorth, lessThan(4000));
    });
  });
}
