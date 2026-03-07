/// Tests for Goal: fromJson, toJson, copyWith, equality, hashCode, computed props, edge cases.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';

Goal _base() => Goal(
  id: 'g1',
  userId: 'u1',
  targetAmount: 1000.0,
  targetDate: DateTime.utc(2026, 12, 31),
  description: 'Save for vacation',
  progress: 250.0,
  category: GoalCategory.vacation,
);

const _kGoalJson = <String, dynamic>{
  'id': 'g1',
  'user_id': 'u1',
  'target_amount': 1000.0,
  'target_date': '2026-12-31T00:00:00.000Z',
  'description': 'Save for vacation',
  'progress': 250.0,
  'category': 'vacation',
};

void main() {
  group('Goal.fromJson', () {
    test('maps all fields correctly', () {
      final g = Goal.fromJson(_kGoalJson);
      expect(g.id, 'g1');
      expect(g.userId, 'u1');
      expect(g.targetAmount, 1000.0);
      expect(g.progress, 250.0);
      expect(g.description, 'Save for vacation');
      expect(g.category, GoalCategory.vacation);
    });

    test('falls back to GoalCategory.other for unknown category', () {
      final g = Goal.fromJson({..._kGoalJson, 'category': 'unicorn'});
      expect(g.category, GoalCategory.other);
    });

    test('throws ArgumentError when target_amount is negative', () {
      expect(
        () => Goal.fromJson({..._kGoalJson, 'target_amount': -1.0}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when progress is negative', () {
      expect(
        () => Goal.fromJson({..._kGoalJson, 'progress': -0.01}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when description is empty', () {
      expect(
        () => Goal.fromJson({..._kGoalJson, 'description': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts target_amount of zero', () {
      final g = Goal.fromJson({..._kGoalJson, 'target_amount': 0.0});
      expect(g.targetAmount, 0.0);
    });
  });

  group('Goal.toJson round-trip', () {
    test('round-trips all fields through toJson/fromJson', () {
      final g = _base();
      final restored = Goal.fromJson(g.toJson());
      expect(restored.id, g.id);
      expect(restored.userId, g.userId);
      expect(restored.targetAmount, g.targetAmount);
      expect(restored.progress, g.progress);
      expect(restored.description, g.description);
      expect(restored.category, g.category);
    });
  });

  group('Goal.copyWith', () {
    test('replaces the specified field', () {
      final copy = _base().copyWith(progress: 500.0);
      expect(copy.progress, 500.0);
    });

    test('preserves unchanged fields', () {
      final original = _base();
      final copy = original.copyWith(progress: 500.0);
      expect(copy.id, original.id);
      expect(copy.targetAmount, original.targetAmount);
      expect(copy.description, original.description);
    });

    test('copyWith with no arguments returns an equal instance', () {
      expect(_base().copyWith(), equals(_base()));
    });

    test('can change the category', () {
      final copy = _base().copyWith(category: GoalCategory.emergency);
      expect(copy.category, GoalCategory.emergency);
    });
  });

  group('Goal equality', () {
    test('two instances with identical fields are equal', () {
      expect(_base(), equals(_base()));
    });

    test('instances differ when id differs', () {
      expect(_base(), isNot(equals(_base().copyWith(id: 'g2'))));
    });

    test('instances differ when progress differs', () {
      expect(_base(), isNot(equals(_base().copyWith(progress: 999.0))));
    });
  });

  group('Goal.hashCode', () {
    test('equal instances have the same hashCode', () {
      expect(_base().hashCode, _base().hashCode);
    });

    test('different instances have different hashCodes (likely)', () {
      expect(_base().hashCode, isNot(_base().copyWith(id: 'x').hashCode));
    });
  });

  group('Goal computed properties', () {
    test('progressPercent is calculated correctly', () {
      expect(_base().progressPercent, 0.25);
    });

    test('progressPercent returns 0 when targetAmount is zero', () {
      final g = _base().copyWith(targetAmount: 0, progress: 0);
      expect(g.progressPercent, 0.0);
    });

    test('progressPercent can exceed 1.0 when progress surpasses target', () {
      final g = _base().copyWith(targetAmount: 100.0, progress: 150.0);
      expect(g.progressPercent, greaterThan(1.0));
    });

    test('isCompleted is false when progress is below target', () {
      expect(_base().isCompleted, isFalse);
    });

    test('isCompleted is true when progress equals target', () {
      final g = Goal(
        id: '1',
        userId: 'u1',
        targetAmount: 500,
        targetDate: DateTime.utc(2026, 6),
        description: 'Emergency fund',
        progress: 500,
        category: GoalCategory.emergency,
      );
      expect(g.isCompleted, isTrue);
    });

    test('isCompleted is true when progress exceeds target', () {
      final g = _base().copyWith(targetAmount: 100.0, progress: 150.0);
      expect(g.isCompleted, isTrue);
    });

    test('remainingAmount is 0 when goal is completed', () {
      final g = _base().copyWith(targetAmount: 500.0, progress: 500.0);
      expect(g.remainingAmount, 0.0);
    });

    test('remainingAmount is correct when partially funded', () {
      expect(_base().remainingAmount, closeTo(750.0, 0.001));
    });

    test('remainingAmount is clamped to 0 when progress exceeds target', () {
      final g = _base().copyWith(targetAmount: 100.0, progress: 200.0);
      expect(g.remainingAmount, 0.0);
    });
  });
}
