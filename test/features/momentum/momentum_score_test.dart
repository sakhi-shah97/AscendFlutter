import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/momentum/application/momentum_score.dart';
import 'package:ascend/shared/models/app_transaction.dart';
import 'package:ascend/shared/models/budget_config.dart';
import 'package:ascend/shared/models/cost_item.dart';
import 'package:ascend/shared/models/savings_account.dart';
import 'package:ascend/shared/models/transaction_type.dart';

AppTransaction _txn(
  TransactionType type,
  double amount,
  DateTime date, {
  String? accountId,
}) {
  return AppTransaction(id: 't-${date.toIso8601String()}-$amount', type: type, amount: amount, date: date, accountId: accountId);
}

void main() {
  final now = DateTime(2026, 3, 15);

  group('savings rate component', () {
    test('earns full 30 pts at a 20%+ rate', () {
      final budget = BudgetConfig(
        monthlyIncome: 10000,
        fixedCosts: const [CostItem(id: 'f1', name: 'Rent', amount: 2000)],
        variableCosts: const [],
      );
      final transactions = [
        _txn(TransactionType.variableExpense, 1000, DateTime(2026, 3, 5)),
        _txn(TransactionType.debtPayment, 500, DateTime(2026, 3, 6)),
      ];
      // expenses = 2000 + 1000 = 3000; liability = 500; savings = 10000 - 3000 - 500 = 6500 -> 65% rate.
      final breakdown = calculateMomentum(transactions: transactions, accounts: const [], budget: budget, now: now);
      expect(breakdown.savingsRate, 30);
    });

    test('scales linearly below 20%', () {
      final budget = BudgetConfig(
        monthlyIncome: 10000,
        fixedCosts: const [CostItem(id: 'f1', name: 'Rent', amount: 2000)],
        variableCosts: const [],
      );
      final transactions = [
        _txn(TransactionType.variableExpense, 6000, DateTime(2026, 3, 5)),
        _txn(TransactionType.debtPayment, 1000, DateTime(2026, 3, 6)),
      ];
      // expenses = 2000 + 6000 = 8000; liability = 1000; savings = 10000 - 8000 - 1000 = 1000 -> 10% rate.
      final breakdown = calculateMomentum(transactions: transactions, accounts: const [], budget: budget, now: now);
      expect(breakdown.savingsRate, closeTo(15, 0.001));
    });

    test('floors at 0 when expenses and debt payments exceed income', () {
      final budget = BudgetConfig(
        monthlyIncome: 1000,
        fixedCosts: const [CostItem(id: 'f1', name: 'Rent', amount: 900)],
        variableCosts: const [],
      );
      final transactions = [_txn(TransactionType.debtPayment, 500, DateTime(2026, 3, 6))];
      final breakdown = calculateMomentum(transactions: transactions, accounts: const [], budget: budget, now: now);
      expect(breakdown.savingsRate, 0);
    });

    test('scores 0 when income is 0', () {
      final breakdown = calculateMomentum(
        transactions: const [],
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.savingsRate, 0);
    });
  });

  group('streak component', () {
    test('counts consecutive improving months, most recent backward', () {
      final transactions = [
        _txn(TransactionType.savingsDeposit, 1000, DateTime(2026, 1, 5)),
        _txn(TransactionType.savingsDeposit, 500, DateTime(2026, 2, 5)),
        _txn(TransactionType.savingsDeposit, 300, DateTime(2026, 3, 5)),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      // Jan: 1000, Feb: 1500 (up), Mar: 1800 (up) -> streak of 2 -> (2/6)*20.
      expect(breakdown.streak, closeTo(2 / 6 * 20, 0.001));
    });

    test('breaks the streak on the most recent non-improving month', () {
      final transactions = [
        _txn(TransactionType.savingsDeposit, 1000, DateTime(2026, 1, 5)),
        _txn(TransactionType.savingsDeposit, 500, DateTime(2026, 2, 5)),
        _txn(TransactionType.savingsWithdrawal, 1500, DateTime(2026, 3, 5)),
        _txn(TransactionType.debtCharge, 200, DateTime(2026, 3, 6)),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.streak, 0);
    });

    test('scores 0 with fewer than 2 months of history', () {
      final transactions = [_txn(TransactionType.savingsDeposit, 1000, DateTime(2026, 3, 5))];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.streak, 0);
    });
  });

  group('debt trend component', () {
    test('earns full 20 pts at a 10%+ monthly reduction', () {
      final transactions = [
        _txn(TransactionType.debtCharge, 1000, DateTime(2026, 2, 5)),
        _txn(TransactionType.debtPayment, 150, DateTime(2026, 3, 5)),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.debtTrend, 20);
    });

    test('scales linearly below a 10% reduction', () {
      final transactions = [
        _txn(TransactionType.debtCharge, 1000, DateTime(2026, 2, 5)),
        _txn(TransactionType.debtPayment, 50, DateTime(2026, 3, 5)),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.debtTrend, closeTo(10, 0.001));
    });

    test('scores 0 when debt is flat or increased', () {
      final transactions = [
        _txn(TransactionType.debtCharge, 1000, DateTime(2026, 2, 5)),
        _txn(TransactionType.debtCharge, 100, DateTime(2026, 3, 5)),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.debtTrend, 0);
    });
  });

  group('emergency fund component', () {
    const account = SavingsAccount(id: 'cash1', name: 'Cash', type: AccountType.cash);
    final budget = BudgetConfig(
      monthlyIncome: 0,
      fixedCosts: const [CostItem(id: 'f1', name: 'Rent', amount: 1000)],
      variableCosts: const [],
    );

    test('earns full 15 pts covering 6+ months of expenses', () {
      final transactions = [_txn(TransactionType.savingsDeposit, 6000, DateTime(2026, 1, 5), accountId: 'cash1')];
      final breakdown = calculateMomentum(transactions: transactions, accounts: const [account], budget: budget, now: now);
      expect(breakdown.emergencyFund, 15);
    });

    test('scales linearly below 6 months of coverage', () {
      final transactions = [_txn(TransactionType.savingsDeposit, 3000, DateTime(2026, 1, 5), accountId: 'cash1')];
      final breakdown = calculateMomentum(transactions: transactions, accounts: const [account], budget: budget, now: now);
      expect(breakdown.emergencyFund, closeTo(7.5, 0.001));
    });

    test('excludes invested savings from the cash total', () {
      const investmentAccount = SavingsAccount(id: 'inv1', name: 'Brokerage', type: AccountType.investment);
      final transactions = [
        _txn(TransactionType.savingsDeposit, 6000, DateTime(2026, 1, 5), accountId: 'inv1'),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [investmentAccount],
        budget: budget,
        now: now,
      );
      expect(breakdown.emergencyFund, 0);
    });
  });

  group('investment ratio component', () {
    const cash = SavingsAccount(id: 'cash1', name: 'Cash', type: AccountType.cash);
    const investment = SavingsAccount(id: 'inv1', name: 'Brokerage', type: AccountType.investment);

    test('earns full 15 pts at a 30%+ invested ratio', () {
      final transactions = [
        _txn(TransactionType.savingsDeposit, 700, DateTime(2026, 1, 5), accountId: 'cash1'),
        _txn(TransactionType.savingsDeposit, 300, DateTime(2026, 1, 6), accountId: 'inv1'),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [cash, investment],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.investmentRatio, 15);
    });

    test('scales linearly below a 30% invested ratio', () {
      final transactions = [
        _txn(TransactionType.savingsDeposit, 850, DateTime(2026, 1, 5), accountId: 'cash1'),
        _txn(TransactionType.savingsDeposit, 150, DateTime(2026, 1, 6), accountId: 'inv1'),
      ];
      final breakdown = calculateMomentum(
        transactions: transactions,
        accounts: const [cash, investment],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.investmentRatio, closeTo(7.5, 0.001));
    });

    test('scores 0 with no savings at all', () {
      final breakdown = calculateMomentum(
        transactions: const [],
        accounts: const [cash, investment],
        budget: BudgetConfig.empty,
        now: now,
      );
      expect(breakdown.investmentRatio, 0);
    });
  });

  group('MomentumBreakdown.total', () {
    test('sums all 5 components', () {
      const breakdown = MomentumBreakdown(
        savingsRate: 30,
        streak: 20,
        debtTrend: 20,
        emergencyFund: 15,
        investmentRatio: 15,
      );
      expect(breakdown.total, 100);
    });

    test('exposes the matching tier', () {
      const breakdown = MomentumBreakdown(savingsRate: 0, streak: 0, debtTrend: 0, emergencyFund: 0, investmentRatio: 0);
      expect(breakdown.tier.label, 'Dormant');
    });
  });
}
