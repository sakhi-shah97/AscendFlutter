import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/momentum/application/momentum_tier.dart';

void main() {
  group('MomentumTier.forScore', () {
    test('returns Dormant at 0', () {
      expect(MomentumTier.forScore(0), MomentumTier.dormant);
      expect(MomentumTier.forScore(9), MomentumTier.dormant);
    });

    test('returns each tier exactly at its lower boundary', () {
      expect(MomentumTier.forScore(10), MomentumTier.seed);
      expect(MomentumTier.forScore(25), MomentumTier.sprout);
      expect(MomentumTier.forScore(40), MomentumTier.sapling);
      expect(MomentumTier.forScore(55), MomentumTier.bloom);
      expect(MomentumTier.forScore(70), MomentumTier.flourish);
      expect(MomentumTier.forScore(85), MomentumTier.thriving);
    });

    test('returns the tier just below a boundary', () {
      expect(MomentumTier.forScore(24), MomentumTier.seed);
      expect(MomentumTier.forScore(84), MomentumTier.flourish);
    });

    test('returns Thriving at the max score', () {
      expect(MomentumTier.forScore(100), MomentumTier.thriving);
    });
  });

  group('MomentumTier.next', () {
    test('returns the following tier', () {
      expect(MomentumTier.next(MomentumTier.dormant), MomentumTier.seed);
      expect(MomentumTier.next(MomentumTier.bloom), MomentumTier.flourish);
    });

    test('returns null after Thriving', () {
      expect(MomentumTier.next(MomentumTier.thriving), isNull);
    });
  });

  test('tiers are strictly ascending by minScore', () {
    for (var i = 1; i < MomentumTier.values.length; i++) {
      expect(MomentumTier.values[i].minScore, greaterThan(MomentumTier.values[i - 1].minScore));
    }
  });
}
