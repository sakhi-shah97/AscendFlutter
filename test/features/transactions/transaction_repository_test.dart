import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/transactions/data/transaction_repository.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(TransactionType type, double amount, DateTime date, {String? category}) {
  return AppTransaction(id: '', type: type, amount: amount, date: date, category: category);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late TransactionRepository repository;
  const uid = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = TransactionRepository(firestore: firestore);
  });

  test('add writes a transaction retrievable via watchTransactions', () async {
    await repository.add(
      uid,
      _txn(TransactionType.variableExpense, 42.5, DateTime(2026, 1, 5), category: 'Groceries'),
    );

    final transactions = await repository.watchTransactions(uid).first;
    expect(transactions, hasLength(1));
    expect(transactions.first.amount, 42.5);
    expect(transactions.first.type, TransactionType.variableExpense);
    expect(transactions.first.category, 'Groceries');
  });

  test('watchTransactions orders newest first', () async {
    await repository.add(uid, _txn(TransactionType.income, 100, DateTime(2026, 1, 1)));
    await repository.add(uid, _txn(TransactionType.income, 200, DateTime(2026, 1, 10)));

    final transactions = await repository.watchTransactions(uid).first;
    expect(transactions.map((t) => t.amount), [200, 100]);
  });

  test('update overwrites an existing transaction', () async {
    await repository.add(uid, _txn(TransactionType.income, 100, DateTime(2026, 1, 1)));
    final [original] = await repository.watchTransactions(uid).first;

    await repository.update(uid, original.copyWith(amount: 150));

    final [updated] = await repository.watchTransactions(uid).first;
    expect(updated.amount, 150);
  });

  test('delete removes a transaction', () async {
    await repository.add(uid, _txn(TransactionType.income, 100, DateTime(2026, 1, 1)));
    final [original] = await repository.watchTransactions(uid).first;

    await repository.delete(uid, original.id);

    expect(await repository.watchTransactions(uid).first, isEmpty);
  });

  test('scopes transactions to the given uid', () async {
    await repository.add(uid, _txn(TransactionType.income, 100, DateTime(2026, 1, 1)));
    expect(await repository.watchTransactions('other-user').first, isEmpty);
  });
}
