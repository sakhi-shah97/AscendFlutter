import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_providers.dart';
import '../../rank/application/net_worth_provider.dart';
import '../../rank/presentation/widgets/hexagon_rank_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final netWorth = ref.watch(netWorthProvider);
    final displayName = user?.displayName;
    final greetingName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user?.email ?? 'ascender');

    return Scaffold(
      appBar: AppBar(title: const Text('Ascend')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Welcome, $greetingName.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                  ),
            ),
            const SizedBox(height: 32),
            Center(child: HexagonRankBadge(netWorth: netWorth)),
          ],
        ),
      ),
    );
  }
}
