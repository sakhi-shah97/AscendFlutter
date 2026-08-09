import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../../shared/widgets/animated_currency_text.dart';
import '../application/net_worth_provider.dart';
import '../application/rank_tier.dart';
import 'widgets/hexagon_rank_badge.dart';

/// Reached by tapping the Home rank badge (which flies into [heroTag] here).
/// Shows the user's current tier, progress toward the next one, and the
/// full tier ladder for context.
class RankDetailScreen extends ConsumerWidget {
  const RankDetailScreen({super.key, this.heroTag = rankBadgeHeroTag});

  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(netWorthProvider);
    final currency = ref.watch(currencyProvider);
    final tier = RankTier.forNetWorth(netWorth);
    final next = RankTier.next(tier);
    final floor = tier?.threshold ?? 0;
    final progress = next == null ? 1.0 : ((netWorth - floor) / (next.threshold - floor)).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(title: Text(tier?.displayName ?? 'Unranked')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Center(
              child: HexagonRankBadge(netWorth: netWorth, size: 220, heroTag: heroTag),
            ),
            const SizedBox(height: 8),
            Center(
              child: AnimatedCurrencyText(
                amount: netWorth,
                currency: currency,
                style: AppTypography.numeric(size: 22, color: AppColors.text),
              ),
            ),
            const SizedBox(height: 24),
            if (next != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: progress.toDouble(), end: progress.toDouble()),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: AppColors.surface2,
                    color: tier?.color ?? AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Next: ${next.displayName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AnimatedCurrencyText(
                            amount: (next.threshold - netWorth).clamp(0, double.infinity),
                            currency: currency,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        Text(' to go', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ] else
              Center(
                child: Text(
                  'Max rank reached.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 32),
            Text('Tier ladder', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final t in RankTier.all) _TierRow(tier: t, current: tier, currency: currency),
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.current, required this.currency});

  final RankTier tier;
  final RankTier? current;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final currentIndex = current == null ? -1 : RankTier.all.indexOf(current!);
    final thisIndex = RankTier.all.indexOf(tier);
    final achieved = thisIndex <= currentIndex;
    final isCurrent = tier == current;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: achieved ? tier.color : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tier.displayName,
              style: (isCurrent
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(color: achieved ? AppColors.text : AppColors.textMuted),
            ),
          ),
          AnimatedCurrencyText(
            amount: tier.threshold,
            currency: currency,
            style: AppTypography.numeric(
              size: 13,
              color: achieved ? tier.color : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
