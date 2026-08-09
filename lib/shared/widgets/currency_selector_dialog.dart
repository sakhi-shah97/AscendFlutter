import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';

/// Shows the currency picker. Returns the selected ISO 4217 code, or null
/// if dismissed without a choice. Used both by Settings and by the
/// first-run currency prompt.
Future<String?> showCurrencySelectorDialog(BuildContext context, {required String current}) {
  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Currency'),
      children: [
        for (final code in supportedCurrencies)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(code),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: code == current
                      ? const Icon(Icons.check, size: 18, color: AppColors.gold)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(code, style: TextStyle(color: AppColors.text)),
              ],
            ),
          ),
      ],
    ),
  );
}
