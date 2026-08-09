import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_transaction.dart';
import '../../auth/application/auth_providers.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// Live-updating list of the signed-in user's transactions, newest first.
/// Empty (not an error) when signed out.
final transactionsProvider = StreamProvider<List<AppTransaction>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(const <AppTransaction>[]);
  return ref.watch(transactionRepositoryProvider).watchTransactions(user.uid);
});

class TransactionController {
  TransactionController(this._ref);
  final Ref _ref;

  String get _uid {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) throw StateError('No signed-in user.');
    return user.uid;
  }

  Future<void> add(AppTransaction transaction) {
    return _ref.read(transactionRepositoryProvider).add(_uid, transaction);
  }

  Future<void> update(AppTransaction transaction) {
    return _ref.read(transactionRepositoryProvider).update(_uid, transaction);
  }

  Future<void> delete(String transactionId) {
    return _ref.read(transactionRepositoryProvider).delete(_uid, transactionId);
  }

  Future<void> deleteAll() {
    return _ref.read(transactionRepositoryProvider).deleteAll(_uid);
  }
}

final transactionControllerProvider = Provider<TransactionController>((ref) {
  return TransactionController(ref);
});
