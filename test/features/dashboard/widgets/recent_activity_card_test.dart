import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(String id, double amount, DateTime date, {String? category}) {
  return AppTransaction(
    id: id,
    type: TransactionType.income,
    amount: amount,
    date: date,
    category: category,
  );
}

void main() {
  testWidgets('shows an empty-state message with no transactions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: RecentActivityCard(transactions: const [], onViewAll: () {})),
        ),
      ),
    );

    expect(find.text('No transactions yet.'), findsOneWidget);
  });

  testWidgets('shows at most 5 transactions', (tester) async {
    final transactions = [
      for (var i = 0; i < 8; i++) _txn('$i', 10.0 + i, DateTime(2026, 1, i + 1), category: 'T$i'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: RecentActivityCard(transactions: transactions, onViewAll: () {})),
        ),
      ),
    );

    expect(find.textContaining('T'), findsNWidgets(5));
  });

  testWidgets('calls onViewAll when the button is pressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: RecentActivityCard(transactions: const [], onViewAll: () => tapped = true),
          ),
        ),
      ),
    );

    await tester.tap(find.text('View all'));
    expect(tapped, isTrue);
  });
}
