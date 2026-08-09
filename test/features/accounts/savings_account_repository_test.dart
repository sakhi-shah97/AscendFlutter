import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/accounts/data/savings_account_repository.dart';
import 'package:ascend/shared/models/savings_account.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SavingsAccountRepository repository;
  const uid = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = SavingsAccountRepository(firestore: firestore);
  });

  test('add writes an account and returns its generated id', () async {
    final id = await repository.add(uid, const SavingsAccount(id: '', name: 'Cash savings', type: AccountType.cash));

    final accounts = await repository.watchAccounts(uid).first;
    expect(accounts, hasLength(1));
    expect(accounts.first.id, id);
    expect(accounts.first.name, 'Cash savings');
    expect(accounts.first.type, AccountType.cash);
  });

  test('fetchOnce mirrors watchAccounts as a one-shot read', () async {
    await repository.add(uid, const SavingsAccount(id: '', name: 'Brokerage', type: AccountType.investment));
    expect(await repository.fetchOnce(uid), hasLength(1));
  });

  test('update overwrites an existing account', () async {
    final id = await repository.add(uid, const SavingsAccount(id: '', name: 'Cash', type: AccountType.cash));
    await repository.update(uid, SavingsAccount(id: id, name: 'Emergency fund', type: AccountType.cash));

    final [updated] = await repository.watchAccounts(uid).first;
    expect(updated.name, 'Emergency fund');
  });

  test('delete removes an account', () async {
    final id = await repository.add(uid, const SavingsAccount(id: '', name: 'Cash', type: AccountType.cash));
    await repository.delete(uid, id);
    expect(await repository.watchAccounts(uid).first, isEmpty);
  });

  test('scopes accounts to the given uid', () async {
    await repository.add(uid, const SavingsAccount(id: '', name: 'Cash', type: AccountType.cash));
    expect(await repository.watchAccounts('other-user').first, isEmpty);
  });
}
