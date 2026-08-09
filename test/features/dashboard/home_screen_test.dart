import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/home_screen.dart';
import 'package:ascend/features/rank/application/net_worth_provider.dart';

void main() {
  testWidgets('shows Unranked at the default (zero) net worth', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Unranked'), findsOneWidget);
  });

  testWidgets('shows the resolved tier for an overridden net worth', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [netWorthProvider.overrideWithValue(750000)],
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Gold I'), findsOneWidget);
  });

  testWidgets('falls back to a generic greeting with no signed-in user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Welcome, ascender'), findsOneWidget);
  });

  testWidgets('shows the trajectory, savings/debt, budget, and activity sections', (tester) async {
    tester.view.physicalSize = const Size(400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Net worth trajectory'), findsOneWidget);
    expect(find.text('Savings vs. debt'), findsOneWidget);
    expect(find.text('Monthly costs'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
  });
}
