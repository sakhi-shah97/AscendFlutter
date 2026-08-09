import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/budget/presentation/widgets/income_form_dialog.dart';

void main() {
  Widget harness(void Function(BuildContext) onPressed) {
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

  testWidgets('pre-fills the current income and returns the edited value', (tester) async {
    double? result;
    await tester.pumpWidget(
      harness((context) async {
        result = await showIncomeFormDialog(context, currentIncome: 5000);
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('5000.00'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '7500');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 7500);
  });

  testWidgets('rejects an empty value', (tester) async {
    await tester.pumpWidget(
      harness((context) => showIncomeFormDialog(context, currentIncome: 5000)),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount.'), findsOneWidget);
  });

  testWidgets('cancel returns null', (tester) async {
    double? result = -1;
    var completed = false;
    await tester.pumpWidget(
      harness((context) async {
        result = await showIncomeFormDialog(context, currentIncome: 5000);
        completed = true;
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(result, isNull);
  });
}
