import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/dashboard/presentation/widgets/level_banner_strip.dart';
import 'package:ascend/features/rank/application/net_worth_provider.dart';

void main() {
  testWidgets('shows Unranked at the default (zero) net worth', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: DashboardStatStrip(children: const [NetLevelPill()])),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Unranked'), findsOneWidget);
  });

  testWidgets('shows the resolved tier and remaining amount to the next level', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [netWorthProvider.overrideWithValue(750000)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: DashboardStatStrip(children: const [NetLevelPill()])),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Gold I'), findsOneWidget);
    expect(find.textContaining('to next level'), findsOneWidget);
  });
}
