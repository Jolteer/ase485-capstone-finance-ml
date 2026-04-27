/// "Add Funds" form shown above the edit form when editing an existing goal.
///
/// Owns its own contribution controller, form key, and saving state so it
/// doesn't entangle with the sibling edit form. Tracks the live progress
/// internally so back-to-back top-ups stack on the latest server-saved value.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';

class GoalContributeForm extends StatefulWidget {
  final Goal initial;

  const GoalContributeForm({super.key, required this.initial});

  @override
  State<GoalContributeForm> createState() => _GoalContributeFormState();
}

class _GoalContributeFormState extends State<GoalContributeForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  late double _currentProgress = widget.initial.progress;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addFunds() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<GoalProvider>();
    final amount = double.parse(_controller.text.trim());
    final newProgress = _currentProgress + amount;

    setState(() => _isSaving = true);
    try {
      await provider.updateGoal(widget.initial.copyWith(progress: newProgress));
      _controller.clear();
      if (mounted) {
        // Track latest saved progress so a second contribution stacks on it
        // instead of re-using the now-stale widget.initial.progress.
        setState(() => _currentProgress = newProgress);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Formatters.currency(amount)} added to goal.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final error = provider.error ?? 'Something went wrong.';
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
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Contribution',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.amount,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: FilledButton(
              onPressed: _isSaving ? null : _addFunds,
              child: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}
