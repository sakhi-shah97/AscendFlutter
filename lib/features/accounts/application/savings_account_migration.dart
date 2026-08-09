import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/savings_account.dart';
import '../../../shared/models/transaction_type.dart';
import '../../auth/application/auth_providers.dart';
import '../../transactions/application/transaction_providers.dart';
import 'savings_account_providers.dart';

/// One-time, idempotent migration for users who logged savings before the
/// accounts feature existed: creates a default "Cash savings" account and
/// tags every pre-existing savings transaction with it, so no historical
/// balance goes uncounted. A no-op for anyone who already has at least one
/// account (new users get the same default seeded on first run too, same
/// spirit as [BudgetConfig.defaultSeed]).
class SavingsAccountMigration {
  SavingsAccountMigration(this._ref);
  final Ref _ref;

  Future<void> run(String uid) async {
    final accountRepo = _ref.read(savingsAccountRepositoryProvider);
    final existingAccounts = await accountRepo.fetchOnce(uid);
    if (existingAccounts.isNotEmpty) return;

    final defaultAccountId = await accountRepo.add(
      uid,
      const SavingsAccount(id: '', name: 'Cash savings', type: AccountType.cash),
    );

    final transactions = await _ref.read(transactionRepositoryProvider).watchTransactions(uid).first;
    final unassignedSavingsIds = transactions
        .where((t) => t.type.kind == TransactionKind.savings && t.accountId == null)
        .map((t) => t.id)
        .toList();

    await _ref.read(transactionRepositoryProvider).backfillAccountId(
          uid,
          accountId: defaultAccountId,
          transactionIds: unassignedSavingsIds,
        );
  }
}

final savingsAccountMigrationProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return;
  await SavingsAccountMigration(ref).run(user.uid);
});
