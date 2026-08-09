import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../data/user_profile_repository.dart';
import '../models/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userProfileRepositoryProvider).watchProfile(user.uid);
});

/// The user's chosen display currency (ISO 4217 code, e.g. "AED") —
/// defaults to AED until their profile loads rather than hardcoding it
/// throughout the UI, so Settings can change it for everyone in one place.
final currencyProvider = Provider<String>((ref) {
  final currency = ref.watch(userProfileProvider).value?.currency;
  return (currency != null && currency.isNotEmpty) ? currency : 'AED';
});
