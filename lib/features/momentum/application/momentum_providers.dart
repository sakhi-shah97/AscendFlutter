import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/budget_config.dart';
import '../../accounts/application/savings_account_providers.dart';
import '../../budget/application/budget_providers.dart';
import '../../transactions/application/transaction_providers.dart';
import 'momentum_score.dart';

/// Live-updating Momentum breakdown for the signed-in user, recomputed
/// from transactions, savings accounts, and budget config. Zero across
/// the board (not an error) while any of those are still loading or the
/// user is signed out.
final momentumProvider = Provider<MomentumBreakdown>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? const [];
  final accounts = ref.watch(savingsAccountsProvider).value ?? const [];
  final budget = ref.watch(budgetProvider).value ?? BudgetConfig.empty;
  return calculateMomentum(transactions: transactions, accounts: accounts, budget: budget, now: DateTime.now());
});
