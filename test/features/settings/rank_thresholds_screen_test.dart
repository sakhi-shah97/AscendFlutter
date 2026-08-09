import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/rank/application/rank_tier.dart';
import 'package:ascend/features/settings/presentation/rank_thresholds_screen.dart';
import 'package:ascend/shared/providers/user_profile_providers.dart';

void main() {
  testWidgets('lists every rank tier with its threshold in the current currency', (tester) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyProvider.overrideWithValue('USD')],
        child: MaterialApp(theme: AppTheme.dark, home: const RankThresholdsScreen()),
      ),
    );

    expect(find.text('Wood I'), findsOneWidget);
    expect(find.text('Radiant III'), findsOneWidget);
    expect(find.text('\$10,000.00'), findsOneWidget);
    expect(find.text('\$12,500,000.00'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(RankTier.all.length));
  });
}
