import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/core/utils/currency.dart';
import 'package:ascend/features/settings/presentation/widgets/currency_selector_dialog.dart';

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

  testWidgets('lists every supported currency', (tester) async {
    await tester.pumpWidget(
      harness((context) => showCurrencySelectorDialog(context, current: 'AED')),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    for (final code in supportedCurrencies) {
      expect(find.text(code), findsOneWidget);
    }
  });

  testWidgets('selecting a currency returns its code', (tester) async {
    String? result;
    await tester.pumpWidget(
      harness((context) async {
        result = await showCurrencySelectorDialog(context, current: 'AED');
      }),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();

    expect(result, 'USD');
  });
}
