import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Auth + Google Sign-In and keeps the /users/{uid} profile
/// document in sync with the authenticated account.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  bool _googleSignInInitialized = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureUserProfile(credential.user!);
  }

  /// Google Sign-In requires different flows per platform in v7: web uses a
  /// full-page redirect (signInWithPopup relies on postMessage + IndexedDB
  /// communication between the popup and opener window, which breaks under
  /// strict Cross-Origin-Opener-Policy headers such as those on proxied dev
  /// domains), while mobile uses the native authenticate() flow and
  /// exchanges the ID token with Firebase.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _auth.signInWithRedirect(GoogleAuthProvider());
      return;
    }

    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureUserProfile(userCredential.user!);
  }

  /// Completes a web signInWithRedirect flow after the page reloads.
  /// No-op if no redirect is pending, and always a no-op off web.
  Future<void> consumeRedirectResult() async {
    if (!kIsWeb) return;
    final credential = await _auth.getRedirectResult();
    final user = credential.user;
    if (user != null) {
      await _ensureUserProfile(user);
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) return;
    await ref.set({
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoUrl': user.photoURL,
      'currency': 'AED',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
