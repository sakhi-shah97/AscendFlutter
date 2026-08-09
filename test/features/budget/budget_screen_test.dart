import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/budget/application/budget_providers.dart';
import 'package:ascend/features/budget/presentation/budget_screen.dart';
import 'package:ascend/features/transactions/application/transaction_providers.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/budget_config.dart';
import 'package:ascend/shared/models/cost_item.dart';
import 'package:ascend/shared/models/transaction_type.dart';

void main() {
  testWidgets('shows income, free cash remaining, and cost lists', (tester) async {
    final budget = BudgetConfig(
      monthlyIncome: 10000,
      fixedCosts: const [CostItem(id: 'rent', name: 'Rent', amount: 3000)],
      variableCosts: const [CostItem(id: 'groceries', name: 'Groceries', amount: 1500)],
    );
    final transactions = [
      AppTransaction(
        id: '1',
        type: TransactionType.variableExpense,
        amount: 500,
        date: DateTime.now(),
        category: 'Groceries',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetProvider.overrideWith((ref) => Stream.value(budget)),
          transactionsProvider.overrideWith((ref) => Stream.value(transactions)),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const BudgetScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('AED 10,000.00'), findsOneWidget);
    expect(find.text('AED 6,500.00'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Groceries'), findsWidgets);
  });

  testWidgets('shows negative remaining with a minus sign', (tester) async {
    final budget = BudgetConfig(
      monthlyIncome: 1000,
      fixedCosts: const [CostItem(id: 'rent', name: 'Rent', amount: 3000)],
      variableCosts: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetProvider.overrideWith((ref) => Stream.value(budget)),
          transactionsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const BudgetScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('−AED 2,000.00'), findsOneWidget);
  });

  testWidgets('shows the empty-spend chart message with no variable spend', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetProvider.overrideWith((ref) => Stream.value(BudgetConfig.empty)),
          transactionsProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const BudgetScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No variable spending logged this month yet.'), findsOneWidget);
  });
}
