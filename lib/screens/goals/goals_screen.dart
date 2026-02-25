import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/widgets/goal_progress_card.dart';

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
          return GoalProgressCard(goal: goal, icon: iconForGoal(goal));
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
