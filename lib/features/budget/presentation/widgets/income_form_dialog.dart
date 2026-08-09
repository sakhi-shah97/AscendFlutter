import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Shows a dialog to edit the monthly income figure. Returns the new value,
/// or null if the user cancelled.
Future<double?> showIncomeFormDialog(BuildContext context, {required double currentIncome}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _IncomeFormDialog(currentIncome: currentIncome),
  );
}

class _IncomeFormDialog extends StatefulWidget {
  const _IncomeFormDialog({required this.currentIncome});

  final double currentIncome;

  @override
  State<_IncomeFormDialog> createState() => _IncomeFormDialogState();
}

class _IncomeFormDialogState extends State<_IncomeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentIncome.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(double.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Monthly income'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: 'Monthly income',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateAmount,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

String? _validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter an amount.';
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 0) return 'Enter a valid amount.';
  return null;
}
