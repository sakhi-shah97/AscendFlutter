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
}
