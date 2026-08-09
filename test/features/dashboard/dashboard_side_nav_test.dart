import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/dashboard_side_nav.dart';

void main() {
  testWidgets('shows all five destinations in order', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: DashboardSideNav(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    for (final label in ['Home', 'Activity', 'Budget', 'Accounts', 'Settings']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('reports the tapped destination index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: DashboardSideNav(currentIndex: 0, onTap: (index) => tapped = index),
        ),
      ),
    );

    await tester.tap(find.text('Budget'));
    expect(tapped, 2);

    await tester.tap(find.text('Settings'));
    expect(tapped, 4);
  });
}
