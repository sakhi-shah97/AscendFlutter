import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/rank/application/net_worth_provider.dart';
import 'package:ascend/features/rank/presentation/rank_detail_screen.dart';

void main() {
  testWidgets('shows the current tier, net worth, and progress to the next tier', (tester) async {
    tester.view.physicalSize = const Size(400, 3400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [netWorthProvider.overrideWithValue(800000)],
        child: MaterialApp(theme: AppTheme.dark, home: const RankDetailScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Gold I'), findsWidgets);
    expect(find.text('AED 800,000.00'), findsOneWidget);
    expect(find.text('Next: Gold II'), findsOneWidget);
    expect(find.text('Tier ladder'), findsOneWidget);
    expect(find.text('Wood I'), findsOneWidget);
    expect(find.text('Radiant III'), findsOneWidget);
  });

  testWidgets('shows a max-rank message at the top tier', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [netWorthProvider.overrideWithValue(20000000)],
        child: MaterialApp(theme: AppTheme.dark, home: const RankDetailScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Max rank reached.'), findsOneWidget);
  });

  testWidgets('shows Unranked with zero net worth', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const RankDetailScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Unranked'), findsWidgets);
    expect(find.text('Next: Wood I'), findsOneWidget);
  });
}
