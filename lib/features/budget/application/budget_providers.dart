import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/budget_config.dart';
import '../../auth/application/auth_providers.dart';
import '../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Live-updating budget config for the signed-in user. [BudgetConfig.empty]
/// when signed out or before the user has ever saved a budget.
final budgetProvider = StreamProvider<BudgetConfig>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(BudgetConfig.empty);
  return ref.watch(budgetRepositoryProvider).watchBudget(user.uid);
});

class BudgetController {
  BudgetController(this._ref);
  final Ref _ref;

  String get _uid {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) throw StateError('No signed-in user.');
    return user.uid;
  }

  Future<void> save(BudgetConfig config) {
    return _ref.read(budgetRepositoryProvider).save(_uid, config);
  }

  Future<void> reset() {
    return _ref.read(budgetRepositoryProvider).reset(_uid);
  }
}

final budgetControllerProvider = Provider<BudgetController>((ref) {
  return BudgetController(ref);
});
