import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../rank/application/rank_tier.dart';

class RankThresholdsScreen extends ConsumerWidget {
  const RankThresholdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rank thresholds')),
      body: ListView.separated(
        itemCount: RankTier.all.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tier = RankTier.all[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: tier.color, radius: 12),
            title: Text(tier.displayName),
            trailing: Text(
              formatCurrency(tier.threshold, currency),
              style: AppTypography.numeric(size: 14, color: tier.color),
            ),
          );
        },
      ),
    );
  }
}
