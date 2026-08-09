import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/savings_debt_chart.dart';

void main() {
  testWidgets('shows savings and debt legend values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SavingsDebtChart(savings: 12000, debt: 3000, currency: 'AED'),
        ),
      ),
    );

    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Debt'), findsOneWidget);
    expect(find.text('AED 12,000.00'), findsOneWidget);
    expect(find.text('AED 3,000.00'), findsOneWidget);
  });
}
