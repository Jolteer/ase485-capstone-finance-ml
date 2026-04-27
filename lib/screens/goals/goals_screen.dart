/// Savings goals list: [GoalProgressCard] for each goal, FAB to add, and tap to edit/contribute.
///
/// Reads [GoalProvider] for live data. [LoadingOverlay] covers the screen while
/// fetching; errors surface as a [SnackBar]. Tapping a card opens [GoalSheet]
/// in edit/contribute mode; the FAB opens it in add mode.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goal_sheet.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/widgets/goal_progress_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Full-screen list of savings goals with progress and "New Goal" FAB.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with ProviderErrorMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<GoalProvider>();
    listenForErrors<GoalProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    if (provider.goals.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) provider.fetchGoals();
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
      builder: (_) => GoalSheet(initial: initial),
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
