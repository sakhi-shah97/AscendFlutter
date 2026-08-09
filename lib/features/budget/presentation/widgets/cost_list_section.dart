import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';
import '../../../../shared/models/cost_item.dart';
import '../../../../shared/providers/user_profile_providers.dart';
import 'cost_item_form_dialog.dart';

/// A single editable list of costs — used for both the fixed and variable
/// costs sections, which share the same "name + AED figure" shape. When
/// [spentByCategory] is supplied (variable costs only), each row also shows
/// actual spend against its budget with a progress bar.
class CostListSection extends ConsumerWidget {
  const CostListSection({
    super.key,
    required this.title,
    required this.items,
    required this.amountLabel,
    required this.onSave,
    required this.onDelete,
    this.spentByCategory,
  });

  final String title;
  final List<CostItem> items;
  final String amountLabel;
  final ValueChanged<CostItem> onSave;
  final ValueChanged<CostItem> onDelete;
  final Map<String, double>? spentByCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final total = items.fold(0.0, (sum, item) => sum + item.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(formatCurrency(total, currency), style: AppTypography.numeric(size: 16)),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No items yet.', style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              for (final item in items)
                _CostRow(
                  item: item,
                  currency: currency,
                  spent: spentByCategory?[item.name],
                  onTap: () async {
                    final result = await showCostItemFormDialog(
                      context,
                      existing: item,
                      amountLabel: amountLabel,
                    );
                    if (result == null) return;
                    if (result.deleted) {
                      onDelete(result.item);
                    } else {
                      onSave(result.item);
                    }
                  },
                ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () async {
                final result = await showCostItemFormDialog(context, amountLabel: amountLabel);
                if (result != null && !result.deleted) onSave(result.item);
              },
              icon: const Icon(Icons.add),
              label: Text('Add ${title.toLowerCase()}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.item,
    required this.currency,
    required this.onTap,
    this.spent,
  });

  final CostItem item;
  final String currency;
  final double? spent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress =
        (spent != null && item.amount > 0) ? (spent! / item.amount).clamp(0, 1).toDouble() : null;
    final overBudget = spent != null && spent! > item.amount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  spent != null
                      ? '${formatCurrency(spent!, currency)} / ${formatCurrency(item.amount, currency)}'
                      : formatCurrency(item.amount, currency),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: overBudget ? AppColors.brick : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surface2,
                  color: overBudget ? AppColors.brick : AppColors.jade,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
