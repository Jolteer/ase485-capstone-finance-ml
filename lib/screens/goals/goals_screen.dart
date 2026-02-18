import 'package:flutter/material.dart';

/// Screen that displays the user’s financial savings goals with
/// visual progress tracking.
///
/// Planned features:
/// • A scrollable list of [GoalProgressCard] widgets.
/// • A [FloatingActionButton] to create a new savings goal.
/// • Swipe-to-delete or long-press to remove completed goals.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(
        // TODO: Display goal list with progress indicators
        child: Text('Goals Screen – Coming Soon'),
      ),
      // FAB to create a new savings goal.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add-goal dialog / screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
