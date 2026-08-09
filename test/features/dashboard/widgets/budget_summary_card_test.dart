import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/budget_summary_card.dart';

void main() {
  testWidgets('shows fixed and variable totals', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: BudgetSummaryCard(
            fixedTotal: 3000,
            variableBudgetTotal: 1500,
            variableSpentTotal: 800,
            currency: 'AED',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('AED 3,000.00'), findsOneWidget);
    expect(find.text('AED 800.00 / AED 1,500.00'), findsOneWidget);
  });

  testWidgets('calls onTap when the card is pressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: BudgetSummaryCard(
            fixedTotal: 0,
            variableBudgetTotal: 0,
            variableSpentTotal: 0,
            currency: 'AED',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
