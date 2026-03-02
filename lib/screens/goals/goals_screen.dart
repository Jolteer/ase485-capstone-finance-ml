import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/utils/utils.dart';
import 'package:ase485_capstone_finance_ml/widgets/widgets.dart';

/// Savings goals screen showing user's financial goals.
/// 
/// Displays a list of savings goals with progress indicators
/// and allows adding new goals.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sampleGoals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final goal = sampleGoals[index];
          return GoalProgressCard(goal: goal, icon: Categories.iconForGoal(goal));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // TODO: implement add goal
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}
