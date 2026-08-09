import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/budget/application/budget_calculations.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/budget_config.dart';
import 'package:ascend/shared/models/cost_item.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(TransactionType type, double amount, DateTime date, {String? category}) {
  return AppTransaction(id: 'id', type: type, amount: amount, date: date, category: category);
}

void main() {
  group('freeCashRemaining', () {
    final budget = BudgetConfig(
      monthlyIncome: 10000,
      fixedCosts: const [CostItem(id: 'rent', name: 'Rent', amount: 3000)],
      variableCosts: const [CostItem(id: 'groceries', name: 'Groceries', amount: 1500)],
    );

    test('subtracts fixed costs and this month\'s actual variable spend', () {
      final transactions = [
        _txn(TransactionType.variableExpense, 500, DateTime(2026, 3, 5)),
        _txn(TransactionType.variableExpense, 300, DateTime(2026, 3, 10)),
      ];
      expect(freeCashRemaining(budget, transactions, DateTime(2026, 3, 15)), 10000 - 3000 - 800);
    });

    test('ignores variable spend from other months', () {
      final transactions = [
        _txn(TransactionType.variableExpense, 500, DateTime(2026, 2, 5)),
      ];
      expect(freeCashRemaining(budget, transactions, DateTime(2026, 3, 15)), 10000 - 3000);
    });

    test('ignores fixed_expense transactions (only the budgeted total counts)', () {
      final transactions = [
        _txn(TransactionType.fixedExpense, 3000, DateTime(2026, 3, 1)),
      ];
      expect(freeCashRemaining(budget, transactions, DateTime(2026, 3, 15)), 10000 - 3000);
    });

    test('can go negative when overspent', () {
      final transactions = [
        _txn(TransactionType.variableExpense, 9000, DateTime(2026, 3, 1)),
      ];
      expect(freeCashRemaining(budget, transactions, DateTime(2026, 3, 15)), 10000 - 3000 - 9000);
    });
  });

  group('totalMonthlyExpenses', () {
    final budget = BudgetConfig(
      monthlyIncome: 10000,
      fixedCosts: const [CostItem(id: 'rent', name: 'Rent', amount: 3000)],
      variableCosts: const [CostItem(id: 'groceries', name: 'Groceries', amount: 1500)],
    );

    test('sums fixed costs and this month\'s actual variable spend (not the budgeted variable total)', () {
      final transactions = [
        _txn(TransactionType.variableExpense, 500, DateTime(2026, 3, 5)),
        _txn(TransactionType.variableExpense, 300, DateTime(2026, 3, 10)),
      ];
      expect(totalMonthlyExpenses(budget, transactions, DateTime(2026, 3, 15)), 3000 + 800);
    });

    test('ignores variable spend from other months', () {
      final transactions = [_txn(TransactionType.variableExpense, 500, DateTime(2026, 2, 5))];
      expect(totalMonthlyExpenses(budget, transactions, DateTime(2026, 3, 15)), 3000);
    });
  });

  group('variableSpendThisMonth', () {
    test('groups this month\'s variable expenses by category', () {
      final transactions = [
        _txn(TransactionType.variableExpense, 100, DateTime(2026, 3, 1), category: 'Groceries'),
        _txn(TransactionType.variableExpense, 50, DateTime(2026, 3, 2), category: 'Groceries'),
        _txn(TransactionType.variableExpense, 40, DateTime(2026, 3, 3), category: 'Dining'),
        _txn(TransactionType.variableExpense, 999, DateTime(2026, 2, 1), category: 'Groceries'),
      ];
      expect(
        variableSpendThisMonth(transactions, DateTime(2026, 3, 20)),
        {'Groceries': 150, 'Dining': 40},
      );
    });
  });
}
