import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.currency,
    this.photoUrl,
    this.createdAt,
  });

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    return UserProfile(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      currency: data['currency'] as String? ?? 'AED',
      photoUrl: data['photoUrl'] as String?,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
    );
  }

  final String uid;
  final String email;
  final String displayName;
  final String currency;
  final String? photoUrl;
  final DateTime? createdAt;

  Map<String, Object?> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'currency': currency,
      'photoUrl': photoUrl,
    };
  }
}
