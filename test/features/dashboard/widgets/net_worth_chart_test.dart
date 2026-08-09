import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/net_worth_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  testWidgets('shows an empty-state message with no history', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: NetWorthChart(history: [], projection: [])),
      ),
    );

    expect(
      find.text('Log a savings or debt transaction to start your net worth history.'),
      findsOneWidget,
    );
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('renders a chart when history is present', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: NetWorthChart(
            history: [
              (date: DateTime(2026, 1, 1), netWorth: 1000.0),
              (date: DateTime(2026, 1, 15), netWorth: 1500.0),
            ],
            projection: [(date: DateTime(2026, 2, 15), netWorth: 2000.0)],
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
  });
}
