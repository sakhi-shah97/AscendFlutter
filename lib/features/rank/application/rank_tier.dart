import 'package:flutter/material.dart';

enum RankGroup {
  wood,
  copper,
  bronze,
  silver,
  gold,
  diamond,
  platinum,
  ascendant,
  radiant;

  String get label => switch (this) {
        RankGroup.wood => 'Wood',
        RankGroup.copper => 'Copper',
        RankGroup.bronze => 'Bronze',
        RankGroup.silver => 'Silver',
        RankGroup.gold => 'Gold',
        RankGroup.diamond => 'Diamond',
        RankGroup.platinum => 'Platinum',
        RankGroup.ascendant => 'Ascendant',
        RankGroup.radiant => 'Radiant',
      };

  /// Base hue for this group's hexagon. Gold and Ascendant intentionally
  /// reuse the app's existing gold/jade accents to tie the rank system into
  /// the wider design system.
  Color get color => switch (this) {
        RankGroup.wood => const Color(0xFF8B6F47),
        RankGroup.copper => const Color(0xFFB5651D),
        RankGroup.bronze => const Color(0xFFB08D57),
        RankGroup.silver => const Color(0xFFB9C0C7),
        RankGroup.gold => const Color(0xFFC7972C),
        RankGroup.diamond => const Color(0xFF6EC3E0),
        RankGroup.platinum => const Color(0xFFD8DCE0),
        RankGroup.ascendant => const Color(0xFF3FAE7C),
        RankGroup.radiant => const Color(0xFFF2CB6B),
      };
}

/// A single named tier (e.g. "Wood I") with its all-time AED threshold.
class RankTier {
  const RankTier({
    required this.group,
    required this.level,
    required this.threshold,
  });

  final RankGroup group;

  /// 1, 2, or 3 — displayed as I, II, III.
  final int level;

  /// Net Financial Level (savings − debt) required to reach this tier, AED.
  final double threshold;

  String get levelLabel => const {1: 'I', 2: 'II', 3: 'III'}[level]!;

  String get displayName => '${group.label} $levelLabel';

  Color get color => group.color;

  /// All 27 tiers, ascending. Radiant III is the max — there's nothing
  /// beyond it, so reaching it naturally caps progression.
  static const List<RankTier> all = [
    RankTier(group: RankGroup.wood, level: 1, threshold: 10000),
    RankTier(group: RankGroup.wood, level: 2, threshold: 25000),
    RankTier(group: RankGroup.wood, level: 3, threshold: 45000),
    RankTier(group: RankGroup.copper, level: 1, threshold: 70000),
    RankTier(group: RankGroup.copper, level: 2, threshold: 100000),
    RankTier(group: RankGroup.copper, level: 3, threshold: 140000),
    RankTier(group: RankGroup.bronze, level: 1, threshold: 190000),
    RankTier(group: RankGroup.bronze, level: 2, threshold: 250000),
    RankTier(group: RankGroup.bronze, level: 3, threshold: 320000),
    RankTier(group: RankGroup.silver, level: 1, threshold: 400000),
    RankTier(group: RankGroup.silver, level: 2, threshold: 500000),
    RankTier(group: RankGroup.silver, level: 3, threshold: 620000),
    RankTier(group: RankGroup.gold, level: 1, threshold: 750000),
    RankTier(group: RankGroup.gold, level: 2, threshold: 900000),
    RankTier(group: RankGroup.gold, level: 3, threshold: 1100000),
    RankTier(group: RankGroup.diamond, level: 1, threshold: 1350000),
    RankTier(group: RankGroup.diamond, level: 2, threshold: 1650000),
    RankTier(group: RankGroup.diamond, level: 3, threshold: 2000000),
    RankTier(group: RankGroup.platinum, level: 1, threshold: 2500000),
    RankTier(group: RankGroup.platinum, level: 2, threshold: 3100000),
    RankTier(group: RankGroup.platinum, level: 3, threshold: 3800000),
    RankTier(group: RankGroup.ascendant, level: 1, threshold: 4600000),
    RankTier(group: RankGroup.ascendant, level: 2, threshold: 5500000),
    RankTier(group: RankGroup.ascendant, level: 3, threshold: 6500000),
    RankTier(group: RankGroup.radiant, level: 1, threshold: 8000000),
    RankTier(group: RankGroup.radiant, level: 2, threshold: 10000000),
    RankTier(group: RankGroup.radiant, level: 3, threshold: 12500000),
  ];

  /// Net Financial Level = total savings − total debt, in AED.
  /// Returns null ("Unranked") if below the Wood I threshold.
  static RankTier? forNetWorth(double netFinancialLevelAed) {
    RankTier? current;
    for (final tier in all) {
      if (netFinancialLevelAed >= tier.threshold) {
        current = tier;
      } else {
        break;
      }
    }
    return current;
  }

  /// The next tier above [current], or null if already at the max (Radiant
  /// III) or if there's no ranked tier reached yet and the caller wants the
  /// tier after a specific one.
  static RankTier? next(RankTier? current) {
    if (current == null) return all.first;
    final index = all.indexOf(current);
    if (index == -1 || index == all.length - 1) return null;
    return all[index + 1];
  }
}
