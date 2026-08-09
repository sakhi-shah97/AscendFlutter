import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/savings_account.dart';
import '../../../shared/providers/user_profile_providers.dart';
import '../../../shared/widgets/animated_currency_text.dart';
import '../../../shared/widgets/press_scale.dart';
import '../../transactions/application/transaction_aggregates.dart';
import '../../transactions/application/transaction_providers.dart';
import '../application/savings_account_migration.dart';
import '../application/savings_account_providers.dart';
import 'widgets/account_form_dialog.dart';

/// Savings accounts (cash and investment) — where a user's savings and
/// investment balances are tracked. Balances are derived live from
/// savings transactions tagged to each account, not stored here.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fire-and-forget: ensures a default cash account exists (and any
    // pre-accounts savings history is linked to it) before this screen's
    // list settles.
    ref.watch(savingsAccountMigrationProvider);

    final accountsAsync = ref.watch(savingsAccountsProvider);
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAccount(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return _AccountCard(
                account: account,
                balance: accountBalance(transactions, account.id),
                currency: currency,
                onTap: () => _editAccount(context, ref, account, transactions),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              "Couldn't load your accounts. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addAccount(BuildContext context, WidgetRef ref) async {
    final result = await showAccountFormDialog(context);
    if (result == null || result.deleted) return;
    await ref.read(savingsAccountControllerProvider).add(result.account);
  }

  Future<void> _editAccount(
    BuildContext context,
    WidgetRef ref,
    SavingsAccount account,
    List<AppTransaction> transactions,
  ) async {
    final result = await showAccountFormDialog(context, existing: account);
    if (result == null) return;
    final controller = ref.read(savingsAccountControllerProvider);
    if (result.deleted) {
      final affectedIds = [
        for (final txn in transactions)
          if (txn.accountId == account.id) txn.id,
      ];
      await ref.read(transactionControllerProvider).clearAccountId(affectedIds);
      await controller.delete(account.id);
    } else {
      await controller.update(result.account);
    }
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.balance,
    required this.currency,
    required this.onTap,
  });

  final SavingsAccount account;
  final double balance;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeColor = account.type == AccountType.investment ? AppColors.gold : AppColors.jade;

    return PressScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  account.type == AccountType.investment ? Icons.trending_up : Icons.savings_outlined,
                  color: typeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(account.type.label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              AnimatedCurrencyText(
                amount: balance,
                currency: currency,
                style: AppTypography.numeric(size: 15, color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
