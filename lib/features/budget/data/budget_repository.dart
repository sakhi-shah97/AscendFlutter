import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/budget_config.dart';

/// Reads/writes the single `users/{uid}/budget/config` document.
class BudgetRepository {
  BudgetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid).collection('budget').doc('config');

  Stream<BudgetConfig> watchBudget(String uid) {
    return _doc(uid).snapshots().map(
          (snapshot) => snapshot.data() == null
              ? BudgetConfig.empty
              : BudgetConfig.fromFirestore(snapshot.data()!),
        );
  }

  Future<void> save(String uid, BudgetConfig config) {
    return _doc(uid).set(config.toFirestore());
  }

  Future<void> reset(String uid) {
    return _doc(uid).delete();
  }
}
