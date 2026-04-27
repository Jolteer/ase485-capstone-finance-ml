/// Form fields for adding or editing a goal: description, target, category,
/// target date, plus action row (delete + save).
///
/// Owns its own controllers, form key, and saving state; pops the enclosing
/// route on success. Caller passes [initial] non-null for edit mode.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';

class GoalEditForm extends StatefulWidget {
  final Goal? initial;

  const GoalEditForm({super.key, this.initial});

  @override
  State<GoalEditForm> createState() => _GoalEditFormState();
}

class _GoalEditFormState extends State<GoalEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  late GoalCategory _category;
  late DateTime _targetDate;
  bool _isSaving = false;

  bool get _isEditMode => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    if (g != null) {
      _descriptionController.text = g.description;
      _targetController.text = g.targetAmount.toStringAsFixed(2);
      _category = g.category;
      _targetDate = g.targetDate;
    } else {
      _category = GoalCategory.other;
      _targetDate = DateTime.now().add(const Duration(days: 365));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<GoalProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final target = double.parse(_targetController.text.trim());
    final description = _descriptionController.text.trim();

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        await provider.updateGoal(
          widget.initial!.copyWith(
            description: description,
            targetAmount: target,
            category: _category,
            targetDate: _targetDate,
          ),
        );
      } else {
        await provider.addGoal(
          Goal(
            id: '',
            userId: userId,
            description: description,
            targetAmount: target,
            progress: 0,
            category: _category,
            targetDate: _targetDate,
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Goal updated.' : 'Goal added.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) _showError(provider);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final provider = context.read<GoalProvider>();
    setState(() => _isSaving = true);
    try {
      await provider.deleteGoal(widget.initial!.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Goal deleted.')));
      }
    } catch (_) {
      if (mounted) _showError(provider);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(GoalProvider provider) {
    final error = provider.error ?? 'Something went wrong.';
    provider.clearError();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: Validators.required('Description'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Target amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.amount,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<GoalCategory>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: GoalCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            leading: const Icon(Icons.calendar_today),
            title: Text('Target: ${Formatters.date(_targetDate)}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _targetDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
              );
              if (picked != null) setState(() => _targetDate = picked);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (_isEditMode)
                TextButton.icon(
                  onPressed: _isSaving ? null : _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isSaving
                      ? 'Saving\u2026'
                      : (_isEditMode ? 'Save Changes' : 'Add Goal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
