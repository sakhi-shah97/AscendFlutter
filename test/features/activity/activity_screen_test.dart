import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/activity/presentation/activity_screen.dart';
import 'package:ascend/features/transactions/application/transaction_providers.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(String id, TransactionType type, double amount, DateTime date, {String? category}) {
  return AppTransaction(id: id, type: type, amount: amount, date: date, category: category);
}

void main() {
  testWidgets('shows an empty state with no transactions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [transactionsProvider.overrideWith((ref) => Stream.value(const []))],
        child: MaterialApp(theme: AppTheme.dark, home: const ActivityScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No transactions yet.\nTap + to add your first one.'), findsOneWidget);
  });

  testWidgets('groups transactions by day with the newest day first', (tester) async {
    final transactions = [
      _txn('1', TransactionType.income, 100, DateTime(2026, 1, 1), category: 'Salary'),
      _txn('2', TransactionType.variableExpense, 20, DateTime(2026, 1, 2), category: 'Coffee'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [transactionsProvider.overrideWith((ref) => Stream.value(transactions))],
        child: MaterialApp(theme: AppTheme.dark, home: const ActivityScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);

    final salaryPos = tester.getTopLeft(find.text('Salary')).dy;
    final coffeePos = tester.getTopLeft(find.text('Coffee')).dy;
    expect(coffeePos, lessThan(salaryPos));
  });

  testWidgets('search filters transactions by category', (tester) async {
    final transactions = [
      _txn('1', TransactionType.income, 100, DateTime(2026, 1, 1), category: 'Salary'),
      _txn('2', TransactionType.variableExpense, 20, DateTime(2026, 1, 1), category: 'Coffee'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [transactionsProvider.overrideWith((ref) => Stream.value(transactions))],
        child: MaterialApp(theme: AppTheme.dark, home: const ActivityScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump();

    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });
}
