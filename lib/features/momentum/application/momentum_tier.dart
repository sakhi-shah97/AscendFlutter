import 'package:flutter/material.dart';

/// The Momentum score's 7 tiers, 0-100. Deliberately named with
/// plant-growth language (not the Net Financial Level rank badge's
/// mined-material language) so the two systems never read as the same
/// thing — Momentum tracks financial *behavior*, the rank badge tracks
/// accumulated *net worth*.
enum MomentumTier {
  dormant,
  seed,
  sprout,
  sapling,
  bloom,
  flourish,
  thriving;

  String get label => switch (this) {
        MomentumTier.dormant => 'Dormant',
        MomentumTier.seed => 'Seed',
        MomentumTier.sprout => 'Sprout',
        MomentumTier.sapling => 'Sapling',
        MomentumTier.bloom => 'Bloom',
        MomentumTier.flourish => 'Flourish',
        MomentumTier.thriving => 'Thriving',
      };

  /// Lowest score (inclusive) that reaches this tier.
  int get minScore => switch (this) {
        MomentumTier.dormant => 0,
        MomentumTier.seed => 10,
        MomentumTier.sprout => 25,
        MomentumTier.sapling => 40,
        MomentumTier.bloom => 55,
        MomentumTier.flourish => 70,
        MomentumTier.thriving => 85,
      };

  Color get color => switch (this) {
        MomentumTier.dormant => const Color(0xFFA89A7E),
        MomentumTier.seed => const Color(0xFF8FA37A),
        MomentumTier.sprout => const Color(0xFF7DBB6E),
        MomentumTier.sapling => const Color(0xFF5B9A54),
        MomentumTier.bloom => const Color(0xFF4F7A54),
        MomentumTier.flourish => const Color(0xFF3D8B4A),
        MomentumTier.thriving => const Color(0xFF2F9E4F),
      };

  /// The tier containing [score] (0-100). [MomentumTier.values] is
  /// declared in ascending threshold order, so the last member whose
  /// [minScore] is at or below [score] wins.
  static MomentumTier forScore(double score) {
    var current = MomentumTier.dormant;
    for (final tier in MomentumTier.values) {
      if (score >= tier.minScore) {
        current = tier;
      } else {
        break;
      }
    }
    return current;
  }

  /// The tier above [current], or null if already [MomentumTier.thriving].
  static MomentumTier? next(MomentumTier current) {
    final index = MomentumTier.values.indexOf(current);
    if (index == MomentumTier.values.length - 1) return null;
    return MomentumTier.values[index + 1];
  }
}
