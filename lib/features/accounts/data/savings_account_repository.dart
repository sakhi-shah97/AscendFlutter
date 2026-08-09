import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/savings_account.dart';

/// CRUD + live stream over a single user's `users/{uid}/savingsAccounts`
/// subcollection.
class SavingsAccountRepository {
  SavingsAccountRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('savingsAccounts');

  Stream<List<SavingsAccount>> watchAccounts(String uid) {
    return _collection(uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => SavingsAccount.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// One-shot read, used by the account migration to decide whether it
  /// still needs to run.
  Future<List<SavingsAccount>> fetchOnce(String uid) async {
    final snapshot = await _collection(uid).get();
    return snapshot.docs.map((doc) => SavingsAccount.fromFirestore(doc.id, doc.data())).toList();
  }

  /// Returns the new document's id, which callers need immediately (e.g.
  /// to tag transactions with it right after creation).
  Future<String> add(String uid, SavingsAccount account) async {
    final doc = await _collection(uid).add(account.toFirestore());
    return doc.id;
  }

  Future<void> update(String uid, SavingsAccount account) {
    return _collection(uid).doc(account.id).update(account.toFirestore());
  }

  Future<void> delete(String uid, String accountId) {
    return _collection(uid).doc(accountId).delete();
  }
}
