import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/transactions/application/transaction_aggregates.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(
  TransactionType type,
  double amount, {
  DateTime? date,
  String? category,
  String id = 'id',
}) {
  return AppTransaction(
    id: id,
    type: type,
    amount: amount,
    date: date ?? DateTime(2026, 1, 1),
    category: category,
  );
}

void main() {
  group('totalSavings / totalDebt / netWorth', () {
    test('savings deposits add, withdrawals subtract', () {
      final txns = [
        _txn(TransactionType.savingsDeposit, 1000),
        _txn(TransactionType.savingsDeposit, 500),
        _txn(TransactionType.savingsWithdrawal, 200),
      ];
      expect(totalSavings(txns), 1300);
    });

    test('debt charges add, payments subtract', () {
      final txns = [
        _txn(TransactionType.debtCharge, 800),
        _txn(TransactionType.debtPayment, 300),
      ];
      expect(totalDebt(txns), 500);
    });

    test('income/expense transactions do not affect savings or debt', () {
      final txns = [
        _txn(TransactionType.income, 5000),
        _txn(TransactionType.fixedExpense, 1200),
        _txn(TransactionType.variableExpense, 300),
      ];
      expect(totalSavings(txns), 0);
      expect(totalDebt(txns), 0);
    });

    test('netWorth is savings minus debt', () {
      final txns = [
        _txn(TransactionType.savingsDeposit, 10000),
        _txn(TransactionType.debtCharge, 4000),
      ];
      expect(netWorth(txns), 6000);
    });
  });

  group('totalForType', () {
    final txns = [
      _txn(TransactionType.variableExpense, 50, date: DateTime(2026, 1, 5)),
      _txn(TransactionType.variableExpense, 30, date: DateTime(2026, 2, 5)),
      _txn(TransactionType.fixedExpense, 1000, date: DateTime(2026, 1, 10)),
    ];

    test('sums only the requested type', () {
      expect(totalForType(txns, TransactionType.variableExpense), 80);
    });

    test('respects a [from, to) window', () {
      final window = currentMonthWindow(DateTime(2026, 1, 15));
      expect(
        totalForType(txns, TransactionType.variableExpense, from: window.start, to: window.end),
        50,
      );
    });
  });

  group('categorySpend', () {
    test('groups by category, defaulting missing ones to Other', () {
      final txns = [
        _txn(TransactionType.variableExpense, 40, category: 'Groceries'),
        _txn(TransactionType.variableExpense, 10, category: 'Groceries'),
        _txn(TransactionType.variableExpense, 25, category: 'Dining'),
        _txn(TransactionType.variableExpense, 15),
        _txn(TransactionType.fixedExpense, 999, category: 'Rent'),
      ];
      final spend = categorySpend(txns, type: TransactionType.variableExpense);
      expect(spend, {'Groceries': 50, 'Dining': 25, 'Other': 15});
    });
  });

  group('currentMonthWindow', () {
    test('spans the first of the month to the first of the next', () {
      final window = currentMonthWindow(DateTime(2026, 2, 17));
      expect(window.start, DateTime(2026, 2, 1));
      expect(window.end, DateTime(2026, 3, 1));
    });

    test('rolls over correctly in December', () {
      final window = currentMonthWindow(DateTime(2026, 12, 5));
      expect(window.start, DateTime(2026, 12, 1));
      expect(window.end, DateTime(2027, 1, 1));
    });
  });

  group('netWorthTrajectory', () {
    test('produces a running cumulative balance in chronological order', () {
      final txns = [
        _txn(TransactionType.debtCharge, 200, date: DateTime(2026, 1, 10)),
        _txn(TransactionType.savingsDeposit, 1000, date: DateTime(2026, 1, 1)),
        _txn(TransactionType.savingsDeposit, 500, date: DateTime(2026, 1, 20)),
      ];
      final trajectory = netWorthTrajectory(txns);

      expect(trajectory.map((p) => p.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 20),
      ]);
      expect(trajectory.map((p) => p.netWorth), [1000, 800, 1300]);
    });

    test('ignores income and expense transactions', () {
      final txns = [
        _txn(TransactionType.income, 5000, date: DateTime(2026, 1, 1)),
        _txn(TransactionType.fixedExpense, 1000, date: DateTime(2026, 1, 2)),
      ];
      expect(netWorthTrajectory(txns), isEmpty);
    });
  });
}
