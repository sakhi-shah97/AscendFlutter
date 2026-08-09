import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/settings/presentation/settings_screen.dart';
import 'package:ascend/shared/providers/user_profile_providers.dart';

void main() {
  testWidgets('shows currency, rank thresholds, sign out, and reset rows', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyProvider.overrideWithValue('USD')],
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('Rank thresholds'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Reset all data'), findsOneWidget);
  });

  testWidgets('tapping Rank thresholds navigates to the thresholds screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    await tester.tap(find.text('Rank thresholds'));
    await tester.pumpAndSettle();

    expect(find.text('Wood I'), findsOneWidget);
  });

  testWidgets('tapping Reset all data shows a confirmation dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    await tester.tap(find.text('Reset all data'));
    await tester.pumpAndSettle();

    expect(find.text('Reset all data?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('cancelling the reset dialog does nothing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    await tester.tap(find.text('Reset all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Reset all data?'), findsNothing);
  });
}
