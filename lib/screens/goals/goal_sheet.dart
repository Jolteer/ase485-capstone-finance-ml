/// Bottom sheet for adding a new goal or editing an existing one.
///
/// Layout-only shell: in edit mode it shows [GoalContributeForm] above
/// [GoalEditForm]; in create mode it just shows [GoalEditForm]. Each form owns
/// its own state so the sheet itself stays stateless.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/widgets/goal_contribute_form.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/widgets/goal_edit_form.dart';

class GoalSheet extends StatelessWidget {
  final Goal? initial;

  const GoalSheet({super.key, this.initial});

  bool get _isEditMode => initial != null;

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
          // Drag-handle pill at the top of the sheet.
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
          if (_isEditMode) ...[
            Text(
              'Add Funds',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GoalContributeForm(initial: initial!),
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
          GoalEditForm(initial: initial),
        ],
      ),
    );
  }
}
