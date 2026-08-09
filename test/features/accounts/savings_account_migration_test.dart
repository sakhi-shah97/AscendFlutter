import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/accounts/application/savings_account_migration.dart';
import 'package:ascend/features/accounts/application/savings_account_providers.dart';
import 'package:ascend/features/accounts/data/savings_account_repository.dart';
import 'package:ascend/features/transactions/application/transaction_providers.dart';
import 'package:ascend/features/transactions/data/transaction_repository.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/savings_account.dart';
import 'package:ascend/shared/models/transaction_type.dart';

const _uid = 'user-1';

/// Exposes [SavingsAccountMigration] via a provider purely so the test can
/// obtain a real [Ref] to construct it with, matching how the app's own
/// [savingsAccountMigrationProvider] does it.
final _migrationProvider = Provider((ref) => SavingsAccountMigration(ref));

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(
      overrides: [
        savingsAccountRepositoryProvider.overrideWithValue(SavingsAccountRepository(firestore: firestore)),
        transactionRepositoryProvider.overrideWithValue(TransactionRepository(firestore: firestore)),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('creates a default cash account and links pre-existing savings transactions to it', () async {
    final transactionRepo = container.read(transactionRepositoryProvider);
    await transactionRepo.add(
      _uid,
      AppTransaction(id: '', type: TransactionType.savingsDeposit, amount: 500, date: DateTime(2026, 1, 1)),
    );
    await transactionRepo.add(
      _uid,
      AppTransaction(id: '', type: TransactionType.debtPayment, amount: 100, date: DateTime(2026, 1, 2)),
    );

    await container.read(_migrationProvider).run(_uid);

    final accountRepo = container.read(savingsAccountRepositoryProvider);
    final accounts = await accountRepo.fetchOnce(_uid);
    expect(accounts, hasLength(1));
    expect(accounts.first.name, 'Cash savings');
    expect(accounts.first.type, AccountType.cash);

    final transactions = await transactionRepo.watchTransactions(_uid).first;
    final savingsTxn = transactions.firstWhere((t) => t.type == TransactionType.savingsDeposit);
    expect(savingsTxn.accountId, accounts.first.id);

    // Non-savings transactions are left untouched.
    final debtTxn = transactions.firstWhere((t) => t.type == TransactionType.debtPayment);
    expect(debtTxn.accountId, isNull);
  });

  test('seeds a default account for a brand-new user with no transactions yet', () async {
    await container.read(_migrationProvider).run(_uid);

    final accounts = await container.read(savingsAccountRepositoryProvider).fetchOnce(_uid);
    expect(accounts, hasLength(1));
  });

  test('is a no-op once an account already exists', () async {
    final accountRepo = container.read(savingsAccountRepositoryProvider);
    await accountRepo.add(_uid, const SavingsAccount(id: '', name: 'My cash', type: AccountType.cash));

    await container.read(_migrationProvider).run(_uid);

    expect(await accountRepo.fetchOnce(_uid), hasLength(1));
  });

  test('never touches savings transactions already tagged with an account', () async {
    final transactionRepo = container.read(transactionRepositoryProvider);
    await transactionRepo.add(
      _uid,
      AppTransaction(
        id: '',
        type: TransactionType.savingsDeposit,
        amount: 500,
        date: DateTime(2026, 1, 1),
        accountId: 'already-tagged',
      ),
    );

    await container.read(_migrationProvider).run(_uid);

    final [txn] = await transactionRepo.watchTransactions(_uid).first;
    expect(txn.accountId, 'already-tagged');
  });
}
