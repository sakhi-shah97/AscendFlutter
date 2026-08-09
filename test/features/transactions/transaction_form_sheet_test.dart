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

  testWidgets('does not show an account field for a non-savings type', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const Scaffold(body: TransactionFormSheet())),
      ),
    );

    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Account'), findsNothing);
  });

  testWidgets('shows an account field once a savings type is selected', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const Scaffold(body: TransactionFormSheet())),
      ),
    );

    // The Type dropdown defaults to "Variable expense" — open it and pick
    // "Savings deposit" instead.
    await tester.tap(find.text('Variable expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings deposit').last);
    await tester.pumpAndSettle();

    // Signed out, so there are no accounts yet — the setup message shows
    // instead of the (still-empty) dropdown.
    expect(find.text('Setting up your default savings account…'), findsOneWidget);
  });
}
