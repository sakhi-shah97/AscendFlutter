import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/rank/application/rank_tier.dart';

void main() {
  group('RankTier.forNetWorth', () {
    test('returns null below the Wood I threshold', () {
      expect(RankTier.forNetWorth(0), isNull);
      expect(RankTier.forNetWorth(9999), isNull);
    });

    test('returns Wood I exactly at its threshold', () {
      expect(RankTier.forNetWorth(10000)?.displayName, 'Wood I');
    });

    test('returns the highest tier at or below the net worth', () {
      expect(RankTier.forNetWorth(69999)?.displayName, 'Wood III');
    });

    test('returns Radiant III at or above the max threshold', () {
      expect(RankTier.forNetWorth(50000000)?.displayName, 'Radiant III');
    });
  });

  group('RankTier.next', () {
    test('returns Wood I when unranked', () {
      expect(RankTier.next(null)?.displayName, 'Wood I');
    });

    test('returns the following tier', () {
      expect(RankTier.next(RankTier.all.first)?.displayName, 'Wood II');
    });

    test('returns null after the max tier', () {
      expect(RankTier.next(RankTier.all.last), isNull);
    });
  });

  group('RankTier.levelLabel / displayName', () {
    test('maps 1/2/3 to roman numerals', () {
      const tier1 = RankTier(group: RankGroup.wood, level: 1, threshold: 0);
      const tier2 = RankTier(group: RankGroup.wood, level: 2, threshold: 0);
      const tier3 = RankTier(group: RankGroup.wood, level: 3, threshold: 0);
      expect(tier1.levelLabel, 'I');
      expect(tier2.levelLabel, 'II');
      expect(tier3.levelLabel, 'III');
      expect(tier1.displayName, 'Wood I');
    });
  });

  test('all tiers are strictly ascending by threshold', () {
    for (var i = 1; i < RankTier.all.length; i++) {
      expect(RankTier.all[i].threshold, greaterThan(RankTier.all[i - 1].threshold));
    }
  });
}
