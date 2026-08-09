import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/savings_account.dart';
import '../../auth/application/auth_providers.dart';
import '../data/savings_account_repository.dart';

final savingsAccountRepositoryProvider = Provider<SavingsAccountRepository>((ref) {
  return SavingsAccountRepository();
});

/// Live-updating list of the signed-in user's savings accounts. Empty
/// (not an error) when signed out or before the one-time migration has
/// created the default account.
final savingsAccountsProvider = StreamProvider<List<SavingsAccount>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(const <SavingsAccount>[]);
  return ref.watch(savingsAccountRepositoryProvider).watchAccounts(user.uid);
});

class SavingsAccountController {
  SavingsAccountController(this._ref);
  final Ref _ref;

  String get _uid {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) throw StateError('No signed-in user.');
    return user.uid;
  }

  Future<String> add(SavingsAccount account) {
    return _ref.read(savingsAccountRepositoryProvider).add(_uid, account);
  }

  Future<void> update(SavingsAccount account) {
    return _ref.read(savingsAccountRepositoryProvider).update(_uid, account);
  }

  Future<void> delete(String accountId) {
    return _ref.read(savingsAccountRepositoryProvider).delete(_uid, accountId);
  }
}

final savingsAccountControllerProvider = Provider<SavingsAccountController>((ref) {
  return SavingsAccountController(ref);
});
