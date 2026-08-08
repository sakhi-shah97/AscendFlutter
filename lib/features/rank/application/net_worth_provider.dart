import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/application/transaction_aggregates.dart' as aggregates;
import '../../transactions/application/transaction_providers.dart';

/// Net Financial Level (total savings − total debt), in AED — derived live
/// from the signed-in user's transaction history. Zero (not an error) while
/// transactions are still loading or the user is signed out.
final netWorthProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? const [];
  return aggregates.netWorth(transactions);
});
