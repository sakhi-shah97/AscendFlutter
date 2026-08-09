import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/budget/presentation/widgets/cost_item_form_dialog.dart';
import 'package:ascend/shared/models/cost_item.dart';

Widget _harness(void Function(BuildContext) onPressed) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onPressed(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('adding: shows a validation error for an empty name', (tester) async {
    await tester.pumpWidget(
      _harness((context) => showCostItemFormDialog(context, amountLabel: 'Monthly amount')),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a name.'), findsOneWidget);
  });

  testWidgets('adding: returns a saved item with trimmed name and parsed amount', (tester) async {
    CostItemFormResult? result;
    await tester.pumpWidget(
      _harness((context) async {
        result = await showCostItemFormDialog(context, amountLabel: 'Monthly amount');
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), ' Rent ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Monthly amount'), '1200');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.deleted, isFalse);
    expect(result!.item.name, 'Rent');
    expect(result!.item.amount, 1200);
  });

  testWidgets('adding: does not show a Delete button', (tester) async {
    await tester.pumpWidget(
      _harness((context) => showCostItemFormDialog(context, amountLabel: 'Monthly amount')),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('editing: pre-fills fields and Delete returns a deleted result', (tester) async {
    const existing = CostItem(id: 'rent', name: 'Rent', amount: 1000);
    CostItemFormResult? result;

    await tester.pumpWidget(
      _harness((context) async {
        result = await showCostItemFormDialog(
          context,
          existing: existing,
          amountLabel: 'Monthly amount',
        );
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('1000.00'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result?.deleted, isTrue);
    expect(result?.item.id, 'rent');
  });
}
