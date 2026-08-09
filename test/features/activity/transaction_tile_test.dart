import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/activity/presentation/widgets/transaction_tile.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/transaction_type.dart';
import 'package:ascend/shared/providers/user_profile_providers.dart';

void main() {
  testWidgets('shows category as title and type as subtitle when categorized', (tester) async {
    final transaction = AppTransaction(
      id: '1',
      type: TransactionType.variableExpense,
      amount: 42.5,
      date: DateTime(2026, 1, 1),
      category: 'Groceries',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyProvider.overrideWithValue('AED')],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: TransactionTile(transaction: transaction, onTap: () {})),
        ),
      ),
    );

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Variable expense'), findsOneWidget);
    expect(find.text('−AED 42.50'), findsOneWidget);
  });

  testWidgets('falls back to the type label as title when uncategorized', (tester) async {
    final transaction = AppTransaction(
      id: '2',
      type: TransactionType.income,
      amount: 5000,
      date: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyProvider.overrideWithValue('USD')],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: TransactionTile(transaction: transaction, onTap: () {})),
        ),
      ),
    );

    expect(find.text('Income'), findsOneWidget);
    expect(find.text('+\$5,000.00'), findsOneWidget);
  });

  testWidgets('calls onTap when pressed', (tester) async {
    var tapped = false;
    final transaction = AppTransaction(
      id: '3',
      type: TransactionType.income,
      amount: 10,
      date: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: TransactionTile(transaction: transaction, onTap: () => tapped = true),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    expect(tapped, isTrue);
  });
}
