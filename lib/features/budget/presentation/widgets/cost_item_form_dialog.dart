import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cost_item.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Result of the add/edit cost dialog: either a saved (new or updated)
/// item, or a request to delete [item] (only offered when editing).
class CostItemFormResult {
  const CostItemFormResult.saved(this.item) : deleted = false;
  const CostItemFormResult.deleted(this.item) : deleted = true;

  final CostItem item;
  final bool deleted;
}

/// Shows the add/edit dialog for a single fixed or variable cost row.
/// [amountLabel] distinguishes "Monthly amount" (fixed) from "Monthly
/// budget" (variable) since the two lists share the same [CostItem] shape.
Future<CostItemFormResult?> showCostItemFormDialog(
  BuildContext context, {
  CostItem? existing,
  required String amountLabel,
}) {
  return showDialog<CostItemFormResult>(
    context: context,
    builder: (context) => _CostItemFormDialog(existing: existing, amountLabel: amountLabel),
  );
}

class _CostItemFormDialog extends StatefulWidget {
  const _CostItemFormDialog({this.existing, required this.amountLabel});

  final CostItem? existing;
  final String amountLabel;

  @override
  State<_CostItemFormDialog> createState() => _CostItemFormDialogState();
}

class _CostItemFormDialogState extends State<_CostItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existing != null ? widget.existing!.amount.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final item = CostItem(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
    );
    Navigator.of(context).pop(CostItemFormResult.saved(item));
  }

  void _delete() {
    Navigator.of(context).pop(CostItemFormResult.deleted(widget.existing!));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(_isEditing ? 'Edit cost' : 'Add cost'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Name',
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a name.' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amountController,
              label: widget.amountLabel,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateAmount,
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.brick),
            child: const Text('Delete'),
          ),
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
  if (parsed == null || parsed <= 0) return 'Enter a valid amount greater than 0.';
  return null;
}
