import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/app_transaction.dart';
import '../../../../shared/providers/user_profile_providers.dart';
import '../../../../shared/widgets/animated_currency_text.dart';
import '../../../../shared/widgets/press_scale.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction, required this.onTap});

  final AppTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final type = transaction.type;
    final hasCategory = (transaction.category?.isNotEmpty ?? false);
    final title = hasCategory ? transaction.category! : type.label;
    final subtitle = hasCategory ? type.label : (transaction.note ?? '');

    return PressScale(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type.color.withValues(alpha: 0.15),
          child: Icon(type.icon, color: type.color),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: AnimatedCurrencyText(
          amount: transaction.amount,
          currency: currency,
          prefix: type.displaySign,
          style: AppTypography.numeric(size: 15, color: type.color),
        ),
      ),
    );
  }
}
