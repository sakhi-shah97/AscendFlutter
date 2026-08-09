import 'package:flutter/material.dart';

import '../../../../shared/models/app_transaction.dart';
import '../../../activity/presentation/widgets/transaction_tile.dart';
import '../../../transactions/presentation/transaction_form_sheet.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, required this.transactions, required this.onViewAll});

  final List<AppTransaction> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final recent = transactions.take(5).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent activity',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(onPressed: onViewAll, child: const Text('View all')),
              ],
            ),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('No transactions yet.', style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              for (final transaction in recent)
                TransactionTile(
                  transaction: transaction,
                  onTap: () => showTransactionFormSheet(context, existing: transaction),
                ),
          ],
        ),
      ),
    );
  }
}
