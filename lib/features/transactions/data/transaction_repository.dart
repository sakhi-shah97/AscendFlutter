import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/app_transaction.dart';

/// CRUD + live stream over a single user's `users/{uid}/transactions`
/// subcollection.
class TransactionRepository {
  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('transactions');

  Stream<List<AppTransaction>> watchTransactions(String uid) {
    return _collection(uid).orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AppTransaction.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> add(String uid, AppTransaction transaction) {
    return _collection(uid).add(transaction.toFirestore());
  }

  Future<void> update(String uid, AppTransaction transaction) {
    return _collection(uid).doc(transaction.id).update(transaction.toFirestore());
  }

  Future<void> delete(String uid, String transactionId) {
    return _collection(uid).doc(transactionId).delete();
  }

  Future<void> deleteAll(String uid) async {
    final snapshot = await _collection(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Stamps [accountId] onto a batch of existing transactions — used by the
  /// one-time savings-account migration to link pre-accounts savings
  /// transactions to the newly-created default account.
  Future<void> backfillAccountId(
    String uid, {
    required String accountId,
    required List<String> transactionIds,
  }) async {
    if (transactionIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in transactionIds) {
      batch.update(_collection(uid).doc(id), {'accountId': accountId});
    }
    await batch.commit();
  }

  /// Un-tags a batch of transactions from a deleted account, so their
  /// amounts fall back to counting as cash (the default for unassigned
  /// savings transactions) rather than disappearing from every account
  /// total.
  Future<void> clearAccountId(String uid, List<String> transactionIds) async {
    if (transactionIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in transactionIds) {
      batch.update(_collection(uid).doc(id), {'accountId': null});
    }
    await batch.commit();
  }
}
