import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Which side of the ledger a [TransactionType] affects. Drives how
/// aggregates (net worth, budget spend) are computed.
enum TransactionKind { income, expense, savings, debt }

enum TransactionType {
  income,
  fixedExpense,
  variableExpense,
  savingsDeposit,
  savingsWithdrawal,
  debtPayment,
  debtCharge;

  /// Stable Firestore value — intentionally decoupled from the Dart enum
  /// member name so renaming a member later can't silently change stored
  /// data.
  String get id => switch (this) {
        TransactionType.income => 'income',
        TransactionType.fixedExpense => 'fixed_expense',
        TransactionType.variableExpense => 'variable_expense',
        TransactionType.savingsDeposit => 'savings_deposit',
        TransactionType.savingsWithdrawal => 'savings_withdrawal',
        TransactionType.debtPayment => 'debt_payment',
        TransactionType.debtCharge => 'debt_charge',
      };

  static TransactionType fromId(String id) => TransactionType.values.firstWhere(
        (type) => type.id == id,
        orElse: () => throw ArgumentError('Unknown transaction type id: $id'),
      );

  String get label => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.fixedExpense => 'Fixed expense',
        TransactionType.variableExpense => 'Variable expense',
        TransactionType.savingsDeposit => 'Savings deposit',
        TransactionType.savingsWithdrawal => 'Savings withdrawal',
        TransactionType.debtPayment => 'Debt payment',
        TransactionType.debtCharge => 'Debt charge',
      };

  TransactionKind get kind => switch (this) {
        TransactionType.income => TransactionKind.income,
        TransactionType.fixedExpense || TransactionType.variableExpense => TransactionKind.expense,
        TransactionType.savingsDeposit || TransactionType.savingsWithdrawal => TransactionKind.savings,
        TransactionType.debtPayment || TransactionType.debtCharge => TransactionKind.debt,
      };

  /// Whether this type increases (true) or decreases (false) its [kind]'s
  /// running balance. Income and charges/deposits/expenses add; payments
  /// and withdrawals subtract.
  bool get isIncrease => switch (this) {
        TransactionType.income => true,
        TransactionType.fixedExpense => true,
        TransactionType.variableExpense => true,
        TransactionType.savingsDeposit => true,
        TransactionType.savingsWithdrawal => false,
        TransactionType.debtPayment => false,
        TransactionType.debtCharge => true,
      };

  /// Sign shown next to the amount in the ledger: "+" for events that read
  /// as a gain (income arriving, savings growing, debt shrinking), "−" for
  /// events that read as a cost (money spent, savings drawn down, debt
  /// growing). Distinct from [isIncrease], which is about which bucket the
  /// amount accumulates into, not how it should look to the user.
  String get displaySign => switch (this) {
        TransactionType.income => '+',
        TransactionType.fixedExpense => '−',
        TransactionType.variableExpense => '−',
        TransactionType.savingsDeposit => '+',
        TransactionType.savingsWithdrawal => '−',
        TransactionType.debtPayment => '+',
        TransactionType.debtCharge => '−',
      };

  IconData get icon => switch (this) {
        TransactionType.income => Icons.arrow_downward,
        TransactionType.fixedExpense => Icons.receipt_long,
        TransactionType.variableExpense => Icons.shopping_bag_outlined,
        TransactionType.savingsDeposit => Icons.savings_outlined,
        TransactionType.savingsWithdrawal => Icons.money_off,
        TransactionType.debtPayment => Icons.check_circle_outline,
        TransactionType.debtCharge => Icons.credit_card,
      };

  Color get color => switch (this) {
        TransactionType.income => AppColors.jade,
        TransactionType.fixedExpense => AppColors.textSecondary,
        TransactionType.variableExpense => AppColors.gold,
        TransactionType.savingsDeposit => AppColors.jade,
        TransactionType.savingsWithdrawal => AppColors.brick,
        TransactionType.debtPayment => AppColors.jade,
        TransactionType.debtCharge => AppColors.brick,
      };
}
