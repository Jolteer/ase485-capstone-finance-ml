/// Savings goals list: [GoalProgressCard] for each goal, FAB to add, and tap to edit/contribute.
///
/// Reads [GoalProvider] for live data. [LoadingOverlay] covers the screen while
/// fetching; errors surface as a [SnackBar]. Tapping a card opens [_GoalSheet]
/// in edit/contribute mode; the FAB opens it in add mode.
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
import 'package:ase485_capstone_finance_ml/widgets/goal_progress_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Full-screen list of savings goals with progress and "New Goal" FAB.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalProvider? _goalProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<GoalProvider>();
    if (_goalProvider != provider) {
      _goalProvider?.removeListener(_onGoalProviderChanged);
      _goalProvider = provider..addListener(_onGoalProviderChanged);
      if (_goalProvider!.goals.isEmpty && !_goalProvider!.isLoading) {
        _goalProvider!.fetchGoals();
      }
    }
  }

  @override
  void dispose() {
    _goalProvider?.removeListener(_onGoalProviderChanged);
    super.dispose();
  }

  void _onGoalProviderChanged() {
    final error = _goalProvider?.error;
    if (error != null && mounted) {
      _goalProvider!.clearError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    }
  }

  void _showGoalSheet({Goal? initial}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.s20),
        ),
      ),
      builder: (_) => _GoalSheet(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final goals = provider.goals;

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Goals')),
        body: goals.isEmpty && !provider.isLoading
            ? const Center(child: Text('No goals yet.\nTap + to create one.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: goals.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.s12),
                itemBuilder: (_, index) {
                  final goal = goals[index];
                  return GoalProgressCard(
                    goal: goal,
                    onTap: () => _showGoalSheet(initial: goal),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'goals_fab',
          onPressed: () => _showGoalSheet(),
          icon: const Icon(Icons.add),
          label: const Text('New Goal'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GoalSheet — add / edit / contribute / delete
// ---------------------------------------------------------------------------

/// Bottom sheet for adding a new goal or editing, contributing to, and deleting
/// an existing one.
///
/// In edit mode ([initial] non-null) a "Add Funds" section appears above the
/// edit form. Contributions are accumulated in local state so back-to-back
/// top-ups each build on the previously saved progress.
class _GoalSheet extends StatefulWidget {
  final Goal? initial;

  const _GoalSheet({this.initial});

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  final _editFormKey = GlobalKey<FormState>();
  final _contributeFormKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _contributionController = TextEditingController();

  late GoalCategory _category;
  late DateTime _targetDate;

  /// Tracks the latest saved progress so successive contributions stack correctly.
  late double _currentProgress;

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
      _currentProgress = g.progress;
    } else {
      _category = GoalCategory.other;
      _targetDate = DateTime.now().add(const Duration(days: 365));
      _currentProgress = 0;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  // ---- actions -------------------------------------------------------------

  Future<void> _addFunds() async {
    if (!(_contributeFormKey.currentState?.validate() ?? false)) return;

    final provider = context.read<GoalProvider>();
    final amount = double.parse(_contributionController.text.trim());
    final newProgress = _currentProgress + amount;

    setState(() => _isSaving = true);
    try {
      await provider.updateGoal(
        widget.initial!.copyWith(progress: newProgress),
      );
      _contributionController.clear();
      if (mounted) {
        setState(() => _currentProgress = newProgress);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Formatters.currency(amount)} added to goal.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) _showError(provider);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _save() async {
    if (!(_editFormKey.currentState?.validate() ?? false)) return;

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

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        bottomInset + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            _isEditMode ? 'Edit Goal' : 'New Goal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),

          // ---- Contribute section (edit mode only) -------------------------
          if (_isEditMode) ...[
            Text(
              'Add Funds',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Form(
              key: _contributeFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contributionController,
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
                    // Align button with text field (accounts for label height).
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: FilledButton(
                      onPressed: _isSaving ? null : _addFunds,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s20),
              child: Divider(),
            ),
            Text(
              'Edit Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
          ],

          // ---- Goal form ---------------------------------------------------
          Form(
            key: _editFormKey,
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                      )
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
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 20),
                      ),
                    );
                    if (picked != null) setState(() => _targetDate = picked);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ---- Action row -------------------------------------------
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
          ),
        ],
      ),
    );
  }
}
