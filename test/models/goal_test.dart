import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';

void main() {
  group('Goal model', () {
    test('progressPercent is calculated correctly', () {
      final goal = Goal(
        id: '1',
        userId: 'u1',
        targetAmount: 1000,
        targetDate: DateTime.utc(2026, 12, 31),
        description: 'Save for vacation',
        progress: 250,
      );
      expect(goal.progressPercent, 0.25);
      expect(goal.isCompleted, false);
    });

    test('isCompleted returns true when progress >= target', () {
      final goal = Goal(
        id: '1',
        userId: 'u1',
        targetAmount: 500,
        targetDate: DateTime.utc(2026, 6),
        description: 'Emergency fund',
        progress: 500,
      );
      expect(goal.isCompleted, true);
    });
  });
}
