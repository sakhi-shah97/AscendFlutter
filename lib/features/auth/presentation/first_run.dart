import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/user_profile_providers.dart';
import '../../../shared/widgets/currency_selector_dialog.dart';

/// Shown right after a brand-new account is created (email sign-up, or a
/// first-time Google sign-in) so the user picks their currency instead of
/// silently keeping the AED default. A no-op if [isNewUser] is false, or if
/// they dismiss the picker — Settings can always change it later.
Future<void> promptForCurrencyIfNewUser(
  BuildContext context,
  WidgetRef ref, {
  required bool isNewUser,
}) async {
  if (!isNewUser) return;
  final currency = await showCurrencySelectorDialog(context, current: 'AED');
  if (currency == null) return;
  if (!context.mounted) return;
  await ref.read(userProfileControllerProvider).updateCurrency(currency);
}
