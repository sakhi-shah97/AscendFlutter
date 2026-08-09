import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_input_decoration.dart';
import '../../../shared/models/app_transaction.dart';
import '../../../shared/models/savings_account.dart';
import '../../../shared/models/transaction_type.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../accounts/application/savings_account_providers.dart';
import '../application/transaction_providers.dart';

/// Opens the add/edit transaction form as a modal bottom sheet. Pass
/// [existing] to edit (and offer delete); omit it to add a new entry.
Future<void> showTransactionFormSheet(BuildContext context, {AppTransaction? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => TransactionFormSheet(existing: existing),
  );
}

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({super.key, this.existing});

  final AppTransaction? existing;

  @override
  ConsumerState<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  late DateTime _date;
  String? _accountId;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? TransactionType.variableExpense;
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(text: existing?.category ?? '');
    _noteController = TextEditingController(text: existing?.note ?? '');
    _date = existing?.date ?? DateTime.now();
    _accountId = existing?.accountId;
  }

  /// The account to use for a savings-kind transaction: the user's
  /// explicit pick if it's still a valid account, otherwise a sensible
  /// default (the first cash account, falling back to the first account
  /// of any type). Null only when there are no accounts to pick from yet.
  String? _resolveAccountId(List<SavingsAccount> accounts) {
    if (_accountId != null && accounts.any((a) => a.id == _accountId)) return _accountId;
    if (accounts.isEmpty) return null;
    return accounts.firstWhere((a) => a.type == AccountType.cash, orElse: () => accounts.first).id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final amount = double.parse(_amountController.text.trim());
    final category = _categoryController.text.trim();
    final note = _noteController.text.trim();
    final controller = ref.read(transactionControllerProvider);
    final accounts = ref.read(savingsAccountsProvider).value ?? const [];
    final accountId = _type.kind == TransactionKind.savings ? _resolveAccountId(accounts) : null;

    try {
      if (_isEditing) {
        await controller.update(
          widget.existing!.copyWith(
            type: _type,
            amount: amount,
            date: _date,
            category: category.isEmpty ? null : category,
            note: note.isEmpty ? null : note,
            accountId: accountId,
          ),
        );
      } else {
        await controller.add(
          AppTransaction(
            id: '',
            type: _type,
            amount: amount,
            date: _date,
            category: category.isEmpty ? null : category,
            note: note.isEmpty ? null : note,
            accountId: accountId,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(transactionControllerProvider).delete(existing.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit transaction' : 'Add transaction',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        onPressed: _isSaving ? null : _delete,
                        icon: const Icon(Icons.delete_outline, color: AppColors.brick),
                        tooltip: 'Delete',
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<TransactionType>(
                  initialValue: _type,
                  decoration: appInputDecoration('Type'),
                  dropdownColor: AppColors.surface,
                  style: TextStyle(color: AppColors.text),
                  items: [
                    for (final type in TransactionType.values)
                      DropdownMenuItem(value: type, child: Text(type.label)),
                  ],
                  onChanged: _isSaving ? null : (value) => setState(() => _type = value!),
                ),
                if (_type.kind == TransactionKind.savings) ...[
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final accounts = ref.watch(savingsAccountsProvider).value ?? const [];
                      if (accounts.isEmpty) {
                        return Text(
                          'Setting up your default savings account…',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }
                      final value = _resolveAccountId(accounts);
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: appInputDecoration('Account'),
                        dropdownColor: AppColors.surface,
                        style: TextStyle(color: AppColors.text),
                        items: [
                          for (final account in accounts)
                            DropdownMenuItem(value: account.id, child: Text(account.name)),
                        ],
                        onChanged: _isSaving ? null : (value) => setState(() => _accountId = value),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _categoryController,
                  label: 'Category (optional)',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _isSaving ? null : _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: appInputDecoration('Date'),
                    child: Text(
                      DateFormat('EEE, MMM d, yyyy').format(_date),
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _noteController,
                  label: 'Note (optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Add transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter an amount.';
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed <= 0) return 'Enter a valid amount greater than 0.';
  return null;
}
