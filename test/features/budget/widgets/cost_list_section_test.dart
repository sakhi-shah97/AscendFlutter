import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/budget/presentation/widgets/cost_list_section.dart';
import 'package:ascend/shared/models/cost_item.dart';

void main() {
  testWidgets('shows items and their total', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CostListSection(
              title: 'Fixed costs',
              items: const [
                CostItem(id: '1', name: 'Rent', amount: 1000),
                CostItem(id: '2', name: 'Utilities', amount: 200),
              ],
              amountLabel: 'Monthly amount',
              onSave: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('AED 1,200.00'), findsOneWidget);
  });

  testWidgets('shows a placeholder when there are no items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CostListSection(
              title: 'Fixed costs',
              items: const [],
              amountLabel: 'Monthly amount',
              onSave: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('No items yet.'), findsOneWidget);
  });

  testWidgets('adding a new item calls onSave with the entered values', (tester) async {
    CostItem? saved;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CostListSection(
              title: 'Fixed costs',
              items: const [],
              amountLabel: 'Monthly amount',
              onSave: (item) => saved = item,
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add fixed costs'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Rent');
    await tester.enterText(find.widgetWithText(TextFormField, 'Monthly amount'), '1000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved?.name, 'Rent');
    expect(saved?.amount, 1000);
  });

  testWidgets('tapping an existing item and deleting calls onDelete', (tester) async {
    CostItem? deleted;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CostListSection(
              title: 'Fixed costs',
              items: const [CostItem(id: 'rent', name: 'Rent', amount: 1000)],
              amountLabel: 'Monthly amount',
              onSave: (_) {},
              onDelete: (item) => deleted = item,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleted?.id, 'rent');
  });

  testWidgets('shows spend progress against budget when spentByCategory is provided', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: CostListSection(
              title: 'Variable costs',
              items: const [CostItem(id: '1', name: 'Groceries', amount: 1000)],
              amountLabel: 'Monthly budget',
              spentByCategory: const {'Groceries': 400},
              onSave: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('AED 400.00 / AED 1,000.00'), findsOneWidget);
  });
}
