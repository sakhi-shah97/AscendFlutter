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

  /// Accent hue for this group — used for text/icons/progress fill, and as
  /// the gem's "base" facet color. Tuned to stay legible against the cream
  /// app background, which rules out literally icy/near-white swatches for
  /// silver and platinum (those live in [facetGradients] instead, where a
  /// bounded gem shape can carry much lighter tones than flat text can).
  Color get color => switch (this) {
        RankGroup.wood => const Color(0xFF6B5636),
        RankGroup.copper => const Color(0xFFA85A1D),
        RankGroup.bronze => const Color(0xFF8C6B3D),
        RankGroup.silver => const Color(0xFF7C8792),
        RankGroup.gold => const Color(0xFFB8842A),
        RankGroup.diamond => const Color(0xFF2A5A6B),
        RankGroup.platinum => const Color(0xFF8FA0AA),
        RankGroup.ascendant => const Color(0xFF2F8F5C),
        RankGroup.radiant => const Color(0xFFB84FC7),
      };

  /// Six 2-stop linear gradients for the faceted gem badge, in facet order
  /// [top, upperRight, lowerRight, bottom, lowerLeft, upperLeft] (each facet
  /// named for the first outer vertex it spans, matching the hexagon's
  /// vertex winding). Gold and Diamond are hand-authored; Diamond is a cool
  /// icy-crystal palette rather than a shade of [color]. Radiant shifts hue
  /// per facet for a prismatic effect; every other tier reuses the same
  /// single-hue light-to-dark shading technique as Gold, seeded from
  /// [color].
  List<List<Color>> get facetGradients => switch (this) {
        RankGroup.gold => const [
            [Color(0xFFB8842A), Color(0xFFFBE8B8)],
            [Color(0xFFE8B84B), Color(0xFF9C6D1F)],
            [Color(0xFF9C6D1F), Color(0xFF6B4A15)],
            [Color(0xFF8A5F1B), Color(0xFF573C11)],
            [Color(0xFF7A5518), Color(0xFFB8842A)],
            [Color(0xFFE8B84B), Color(0xFFFDF3D9)],
          ],
        RankGroup.diamond => const [
            [Color(0xFF7FC4E3), Color(0xFFFFFFFF)],
            [Color(0xFFC9E8F5), Color(0xFF4A8FA8)],
            [Color(0xFF4A8FA8), Color(0xFF2A5A6B)],
            [Color(0xFF3D7A94), Color(0xFF1F4552)],
            [Color(0xFF2A5A6B), Color(0xFF7FC4E3)],
            [Color(0xFFC9E8F5), Color(0xFFFFFFFF)],
          ],
        RankGroup.radiant => prismaticFacetGradients(),
        _ => singleHueFacetGradients(color),
      };

  /// True for the tier that gets the extra diamond-fire twinkle dots.
  bool get hasTwinkle => this == RankGroup.diamond;
}

/// Per-facet lightness deltas (relative to a seed color's own HSL lightness)
/// that reproduce the Gold tier's hand-authored shading — derived by
/// measuring Gold's own facet colors against its base. Order matches
/// [RankGroup.facetGradients]: top, upperRight, lowerRight, bottom,
/// lowerLeft, upperLeft; each pair is [nearStop, farStop] running from
/// center-side to outer-edge-side of the facet.
const _facetLightnessDeltas = [
  [0.0, 0.410],
  [0.159, -0.076],
  [-0.076, -0.192],
  [-0.119, -0.239],
  [-0.157, 0.0],
  [0.159, 0.479],
];

/// Shades [base] light-to-dark across all six facets using
/// [_facetLightnessDeltas], keeping hue and saturation constant — the
/// "single hue shaded light to dark" technique used by most tiers.
List<List<Color>> singleHueFacetGradients(Color base) {
  final hsl = HSLColor.fromColor(base);
  Color at(double delta) =>
      hsl.withLightness((hsl.lightness + delta).clamp(0.05, 0.97)).toColor();
  return [
    for (final pair in _facetLightnessDeltas)
      [
        pair[0] == 0.0 ? base : at(pair[0]),
        pair[1] == 0.0 ? base : at(pair[1]),
      ],
  ];
}

/// Same shading technique as [singleHueFacetGradients], but each facet gets
/// its own hue stepped around the color wheel for Radiant's prismatic gem.
List<List<Color>> prismaticFacetGradients() {
  const hues = [45.0, 330.0, 280.0, 220.0, 170.0, 100.0];
  const saturation = 0.70;
  const baseLightness = 0.50;
  Color at(double hue, double delta) => HSLColor.fromAHSL(
        1,
        hue,
        saturation,
        (baseLightness + delta).clamp(0.05, 0.97),
      ).toColor();
  return [
    for (var i = 0; i < 6; i++)
      [at(hues[i], _facetLightnessDeltas[i][0]), at(hues[i], _facetLightnessDeltas[i][1])],
  ];
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
