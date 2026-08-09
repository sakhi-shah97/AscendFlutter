import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../../shared/widgets/currency_selector_dialog.dart';
import '../../../shared/widgets/press_scale.dart';
import '../../auth/application/auth_providers.dart';
import '../../budget/application/budget_providers.dart';
import '../../transactions/application/transaction_providers.dart';
import 'rank_thresholds_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently deletes every transaction and your budget setup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.brick),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(transactionControllerProvider).deleteAll();
    await ref.read(budgetControllerProvider).reset();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          PressScale(
            onTap: () async {
              final selected = await showCurrencySelectorDialog(context, current: currency);
              if (selected != null && selected != currency) {
                await ref.read(userProfileControllerProvider).updateCurrency(selected);
              }
            },
            child: ListTile(
              title: const Text('Currency'),
              trailing: Text(currency, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          PressScale(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RankThresholdsScreen()),
            ),
            child: ListTile(
              title: const Text('Rank thresholds'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            enabled: !isLoading,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.brick),
            title: const Text('Reset all data', style: TextStyle(color: AppColors.brick)),
            subtitle: const Text('Deletes all transactions and your budget. Cannot be undone.'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }
}
