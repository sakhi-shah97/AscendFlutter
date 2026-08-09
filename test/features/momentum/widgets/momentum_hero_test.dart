import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/momentum/application/momentum_score.dart';
import 'package:ascend/features/momentum/presentation/widgets/momentum_hero.dart';

void main() {
  Future<void> pumpHero(WidgetTester tester, MomentumBreakdown breakdown, {double netWorth = 0}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: MomentumHero(breakdown: breakdown, netWorth: netWorth, currency: 'AED'),
        ),
      ),
    );
  }

  testWidgets('shows the Dormant tier and score at zero', (tester) async {
    const breakdown = MomentumBreakdown(
      savingsRate: 0,
      streak: 0,
      debtTrend: 0,
      emergencyFund: 0,
      investmentRatio: 0,
    );
    await pumpHero(tester, breakdown);
    await tester.pump(const Duration(seconds: 2)); // let the ring fill animation settle

    // "Dormant" appears twice: the headline and its entry in the tier ladder.
    expect(find.text('Dormant'), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
    expect(find.text('of 100'), findsOneWidget);
    expect(find.text('10 pts to Seed'), findsOneWidget);
  });

  testWidgets('shows the resolved tier and breakdown chips at a mid score', (tester) async {
    const breakdown = MomentumBreakdown(
      savingsRate: 15,
      streak: 10,
      debtTrend: 10,
      emergencyFund: 7.5,
      investmentRatio: 7.5,
    );
    await pumpHero(tester, breakdown);
    await tester.pump(const Duration(seconds: 2));

    // total 50 -> Sapling tier (40-54); "Sapling" appears in the headline and the tier ladder.
    expect(find.text('Sapling'), findsNWidgets(2));
    expect(find.text('Savings rate'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Debt trend'), findsOneWidget);
    expect(find.text('Emergency fund'), findsOneWidget);
  });

  testWidgets('shows a top-tier message with no next tier', (tester) async {
    const breakdown = MomentumBreakdown(
      savingsRate: 30,
      streak: 20,
      debtTrend: 20,
      emergencyFund: 15,
      investmentRatio: 15,
    );
    await pumpHero(tester, breakdown);
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Thriving'), findsNWidgets(2));
    expect(find.text("You've reached the top tier"), findsOneWidget);
  });
}
