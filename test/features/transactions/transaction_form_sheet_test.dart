import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/transactions/presentation/transaction_form_sheet.dart';

void main() {
  testWidgets('shows a validation error for an empty amount', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: TransactionFormSheet()),
        ),
      ),
    );

    await tester.tap(find.text('Add transaction').last);
    await tester.pump();

    expect(find.text('Enter an amount.'), findsOneWidget);
  });

  testWidgets('shows a validation error for a non-positive amount', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: TransactionFormSheet()),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '-5');
    await tester.tap(find.text('Add transaction').last);
    await tester.pump();

    expect(find.text('Enter a valid amount greater than 0.'), findsOneWidget);
  });

  testWidgets('does not show a delete button when adding', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const Scaffold(body: TransactionFormSheet())),
      ),
    );

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
