import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/widgets/goal_progress_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleGoals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final goal = _sampleGoals[index];
          return GoalProgressCard(goal: goal, icon: _iconForGoal(goal));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}

IconData _iconForGoal(Goal goal) {
  final desc = goal.description.toLowerCase();
  if (desc.contains('vacation')) return Icons.beach_access;
  if (desc.contains('down payment') || desc.contains('home')) {
    return Icons.home;
  }
  if (desc.contains('emergency')) return Icons.warning_amber;
  if (desc.contains('car')) return Icons.directions_car;
  return Icons.flag;
}

final _sampleGoals = [
  Goal(
    id: '1',
    userId: 'demo',
    description: 'Vacation Fund',
    progress: 1800,
    targetAmount: 3000,
    targetDate: DateTime(2026, 6),
  ),
  Goal(
    id: '2',
    userId: 'demo',
    description: 'Down Payment',
    progress: 12000,
    targetAmount: 50000,
    targetDate: DateTime(2027, 12),
  ),
  Goal(
    id: '3',
    userId: 'demo',
    description: 'Emergency Fund',
    progress: 5000,
    targetAmount: 5000,
    targetDate: DateTime(2026, 1),
  ),
  Goal(
    id: '4',
    userId: 'demo',
    description: 'New Car',
    progress: 3200,
    targetAmount: 15000,
    targetDate: DateTime(2027, 3),
  ),
];
