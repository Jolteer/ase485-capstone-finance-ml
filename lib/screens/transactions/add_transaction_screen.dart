/// Form to add or edit an income/expense transaction.
///
/// When [initial] is provided the form pre-fills with its values and calls
/// [TransactionProvider.updateTransaction] on save; otherwise calls [addTransaction].
/// Shows a success [SnackBar] and pops on success, or an error [SnackBar] on failure.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Add/edit transaction form. Pass [initial] to pre-fill for editing.
class AddTransactionScreen extends StatefulWidget {
  /// When non-null, the form is in edit mode and saves via [TransactionProvider.updateTransaction].
  final Transaction? initial;

  const AddTransactionScreen({super.key, this.initial});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionCategory _category = TransactionCategory.food;

  /// True = expense (stored as negative), false = income (positive).
  bool _isExpense = true;

  /// Transaction date; user can change via the date picker.
  DateTime _date = DateTime.now();

  /// True while the save request is in flight; disables the button.
  bool _isSaving = false;

  bool get _isEditMode => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _amountController.text = t.absAmount.toStringAsFixed(2);
      _descriptionController.text = t.description;
      _category = t.category;
      _isExpense = t.isExpense;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rawAmount = double.parse(_amountController.text.trim());
    final amount = _isExpense ? -rawAmount.abs() : rawAmount.abs();
    final description = _descriptionController.text.trim();

    final provider = context.read<TransactionProvider>();

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        await provider.updateTransaction(
          widget.initial!.copyWith(
            amount: amount,
            category: _category,
            description: description,
            date: _date,
          ),
        );
      } else {
        final userId = context.read<AuthProvider>().currentUser?.id ?? '';
        await provider.addTransaction(
          Transaction(
            id: '',
            userId: userId,
            amount: amount,
            category: _category,
            description: description,
            date: _date,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Transaction updated.' : 'Transaction added.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        final error = provider.error ?? 'Failed to save transaction.';
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Expense')),
                    ButtonSegment(value: false, label: Text('Income')),
                  ],
                  selected: {_isExpense},
                  onSelectionChanged: (v) =>
                      setState(() => _isExpense = v.first),
                ),
                const SizedBox(height: AppSpacing.s20),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TransactionCategory.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.required('Description'),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  title: Text(Formatters.date(_date)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365 * 5),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isSaving ? 'Saving\u2026' : 'Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
