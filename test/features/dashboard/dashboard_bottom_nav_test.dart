import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart';

void main() {
  testWidgets('shows all five tabs in order', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: DashboardBottomNav(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    for (final label in ['Home', 'Activity', 'Budget', 'Accounts', 'Settings']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('reports the tapped tab index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: DashboardBottomNav(
            currentIndex: 0,
            onTap: (index) => tapped = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Budget'));
    expect(tapped, 2);

    await tester.tap(find.text('Settings'));
    expect(tapped, 4);
  });
}
