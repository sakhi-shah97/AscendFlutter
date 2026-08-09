import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/app_transaction.dart';
import '../../transactions/application/transaction_providers.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';
import 'widgets/transaction_tile.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Search transactions',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: switch (transactionsAsync) {
                AsyncData(:final value) => _ActivityList(transactions: value, query: _query),
                AsyncError() => const _ErrorState(),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.transactions, required this.query});

  final List<AppTransaction> transactions;
  final String query;

  bool _matches(AppTransaction transaction) {
    if (query.isEmpty) return true;
    return transaction.type.label.toLowerCase().contains(query) ||
        (transaction.category?.toLowerCase().contains(query) ?? false) ||
        (transaction.note?.toLowerCase().contains(query) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where(_matches).toList();

    if (transactions.isEmpty) {
      return const _EmptyState(
        message: 'No transactions yet.\nTap + to add your first one.',
      );
    }
    if (filtered.isEmpty) {
      return const _EmptyState(message: 'No transactions match your search.');
    }

    final grouped = <DateTime, List<AppTransaction>>{};
    for (final transaction in filtered) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      (grouped[day] ??= []).add(transaction);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final dayTransactions = grouped[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(_dayLabel(day), style: Theme.of(context).textTheme.labelMedium),
            ),
            for (final transaction in dayTransactions)
              TransactionTile(
                transaction: transaction,
                onTap: () => showTransactionFormSheet(context, existing: transaction),
              ),
          ],
        );
      },
    );
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    return DateFormat('EEE, MMM d, yyyy').format(day);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          "Couldn't load your transactions. Check your connection and try again.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
