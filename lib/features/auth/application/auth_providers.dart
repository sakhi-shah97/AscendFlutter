import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Completes a pending Google signInWithRedirect flow, if the app just
    // reloaded after returning from Google's sign-in page.
    return _repository.consumeRedirectResult();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signInWithEmail(email: email, password: password),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signUpWithEmail(email: email, password: password),
    );
  }

  /// Returns whether this sign-in created a brand-new account (see
  /// [AuthRepository.signInWithGoogle]) — the caller uses this to decide
  /// whether to prompt for a currency choice. False on any error/cancel.
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    var isNewUser = false;
    state = await AsyncValue.guard(() async {
      try {
        isNewUser = await _repository.signInWithGoogle();
      } on GoogleSignInException catch (e) {
        // A user-dismissed picker isn't an error worth surfacing.
        if (e.code == GoogleSignInExceptionCode.canceled) return;
        rethrow;
      }
    });
    return isNewUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.sendPasswordResetEmail(email),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
