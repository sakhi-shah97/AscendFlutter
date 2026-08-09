import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/shared/models/transaction_type.dart';

void main() {
  test('every type round-trips through its Firestore id', () {
    for (final type in TransactionType.values) {
      expect(TransactionType.fromId(type.id), type);
    }
  });

  test('fromId throws for an unknown id', () {
    expect(() => TransactionType.fromId('not-a-real-type'), throwsArgumentError);
  });

  test('kind groups types correctly', () {
    expect(TransactionType.income.kind, TransactionKind.income);
    expect(TransactionType.fixedExpense.kind, TransactionKind.expense);
    expect(TransactionType.variableExpense.kind, TransactionKind.expense);
    expect(TransactionType.savingsDeposit.kind, TransactionKind.savings);
    expect(TransactionType.savingsWithdrawal.kind, TransactionKind.savings);
    expect(TransactionType.debtPayment.kind, TransactionKind.debt);
    expect(TransactionType.debtCharge.kind, TransactionKind.debt);
  });

  test('displaySign reads gains as + and costs as -', () {
    expect(TransactionType.income.displaySign, '+');
    expect(TransactionType.savingsDeposit.displaySign, '+');
    expect(TransactionType.debtPayment.displaySign, '+');
    expect(TransactionType.fixedExpense.displaySign, '−');
    expect(TransactionType.variableExpense.displaySign, '−');
    expect(TransactionType.savingsWithdrawal.displaySign, '−');
    expect(TransactionType.debtCharge.displaySign, '−');
  });
}
