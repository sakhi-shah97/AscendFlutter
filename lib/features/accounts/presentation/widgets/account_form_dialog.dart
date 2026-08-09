import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_input_decoration.dart';
import '../../../../shared/models/savings_account.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Result of the add/edit account dialog: either a saved (new or updated)
/// account, or a request to delete [account] (only offered when editing).
class AccountFormResult {
  const AccountFormResult.saved(this.account) : deleted = false;
  const AccountFormResult.deleted(this.account) : deleted = true;

  final SavingsAccount account;
  final bool deleted;
}

/// Shows the add/edit dialog for a single savings account.
Future<AccountFormResult?> showAccountFormDialog(BuildContext context, {SavingsAccount? existing}) {
  return showDialog<AccountFormResult>(
    context: context,
    builder: (context) => _AccountFormDialog(existing: existing),
  );
}

class _AccountFormDialog extends StatefulWidget {
  const _AccountFormDialog({this.existing});

  final SavingsAccount? existing;

  @override
  State<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<_AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late AccountType _type;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final account = SavingsAccount(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      type: _type,
    );
    Navigator.of(context).pop(AccountFormResult.saved(account));
  }

  void _delete() {
    Navigator.of(context).pop(AccountFormResult.deleted(widget.existing!));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(_isEditing ? 'Edit account' : 'Add account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Name',
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a name.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: appInputDecoration('Type'),
              dropdownColor: AppColors.surface,
              style: TextStyle(color: AppColors.text),
              items: [
                for (final type in AccountType.values) DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) => setState(() => _type = value!),
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
