import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map(
          (snapshot) =>
              snapshot.data() == null ? null : UserProfile.fromFirestore(uid, snapshot.data()!),
        );
  }

  Future<void> updateCurrency(String uid, String currency) {
    return _doc(uid).update({'currency': currency});
  }
}
