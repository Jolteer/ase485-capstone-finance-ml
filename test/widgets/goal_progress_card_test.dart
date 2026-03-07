/// Widget tests for GoalProgressCard: description, progress bar, "Done" chip,
/// target date text, and onTap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/widgets/goal_progress_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Goal _makeGoal({
  String description = 'Vacation fund',
  double target = 5000.0,
  double progress = 1000.0,
  GoalCategory category = GoalCategory.vacation,
}) => Goal(
  id: 'g1',
  userId: 'u1',
  targetAmount: target,
  targetDate: DateTime.utc(2027, 12, 31),
  description: description,
  progress: progress,
  category: category,
);

void main() {
  group('GoalProgressCard', () {
    testWidgets('renders the goal description', (tester) async {
      await tester.pumpWidget(
        _wrap(GoalProgressCard(goal: _makeGoal(description: 'Vacation fund'))),
      );
      expect(find.text('Vacation fund'), findsOneWidget);
    });

    testWidgets('renders a LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(GoalProgressCard(goal: _makeGoal())));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('progress bar value reflects progress/target ratio', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          GoalProgressCard(goal: _makeGoal(target: 1000.0, progress: 250.0)),
        ),
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.25, 0.001));
    });

    testWidgets('shows "Done" chip when goal is completed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GoalProgressCard(goal: _makeGoal(target: 500.0, progress: 500.0)),
        ),
      );
      expect(find.text('Done'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('hides "Done" chip when goal is not completed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GoalProgressCard(goal: _makeGoal(target: 1000.0, progress: 200.0)),
        ),
      );
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('shows target date text', (tester) async {
      await tester.pumpWidget(_wrap(GoalProgressCard(goal: _makeGoal())));
      expect(find.textContaining('Target:'), findsOneWidget);
    });

    testWidgets('clamps progress bar to 1.0 when progress exceeds target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          GoalProgressCard(goal: _makeGoal(target: 100.0, progress: 150.0)),
        ),
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 1.0);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(GoalProgressCard(goal: _makeGoal(), onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('accepts a custom icon without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(GoalProgressCard(goal: _makeGoal(), icon: Icons.star)),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows progress bar at 0 when targetAmount is zero', (
      tester,
    ) async {
      final zeroTarget = Goal(
        id: 'g0',
        userId: 'u1',
        targetAmount: 0,
        targetDate: DateTime.utc(2027),
        description: 'Zero target',
        progress: 0,
        category: GoalCategory.other,
      );
      await tester.pumpWidget(_wrap(GoalProgressCard(goal: zeroTarget)));

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.0);
    });
  });
}
