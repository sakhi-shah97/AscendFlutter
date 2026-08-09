import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Linked accounts', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                "Connecting a bank or card isn't available yet — for now, log balances as transactions in Activity.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
