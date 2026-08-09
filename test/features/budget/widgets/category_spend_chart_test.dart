import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/budget/presentation/widgets/category_spend_chart.dart';

void main() {
  testWidgets('shows an empty message with no spend', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: CategorySpendChart(spendByCategory: {}, currency: 'AED')),
      ),
    );

    expect(find.text('No variable spending logged this month yet.'), findsOneWidget);
  });

  testWidgets('shows a legend row per category with formatted amount and percentage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: CategorySpendChart(
            spendByCategory: {'Groceries': 75, 'Dining': 25},
            currency: 'AED',
          ),
        ),
      ),
    );

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Dining'), findsOneWidget);
    expect(find.text('AED 75.00'), findsOneWidget);
    expect(find.text('AED 25.00'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });
}
