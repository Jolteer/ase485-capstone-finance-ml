/// Tests for Budget: fromJson, toJson, copyWith, equality, hashCode, and edge cases.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

Budget _base() => Budget(
  id: 'b1',
  userId: 'u1',
  category: TransactionCategory.food,
  limitAmount: 500.0,
  period: BudgetPeriod.monthly,
  createdAt: DateTime.utc(2026, 1, 1),
);

const _kBudgetJson = <String, dynamic>{
  'id': '1',
  'user_id': 'u1',
  'category': 'Food',
  'limit_amount': 500.0,
  'period': 'monthly',
  'created_at': '2026-01-01T00:00:00.000Z',
};

void main() {
  group('Budget.fromJson', () {
    test('maps all fields correctly', () {
      final b = Budget.fromJson(_kBudgetJson);
      expect(b.id, '1');
      expect(b.userId, 'u1');
      expect(b.category, TransactionCategory.food);
      expect(b.limitAmount, 500.0);
      expect(b.period, BudgetPeriod.monthly);
    });

    test('parses createdAt as UTC DateTime', () {
      final b = Budget.fromJson(_kBudgetJson);
      expect(b.createdAt, DateTime.utc(2026, 1, 1));
    });

    test('falls back to monthly for unknown period string', () {
      final b = Budget.fromJson({..._kBudgetJson, 'period': 'quinquennially'});
      expect(b.period, BudgetPeriod.monthly);
    });

    test('throws ArgumentError when limit_amount is zero', () {
      expect(
        () => Budget.fromJson({..._kBudgetJson, 'limit_amount': 0}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when limit_amount is negative', () {
      expect(
        () => Budget.fromJson({..._kBudgetJson, 'limit_amount': -100}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Budget.toJson round-trip', () {
    test('round-trips all fields through toJson/fromJson', () {
      final b = _base();
      final restored = Budget.fromJson(b.toJson());
      expect(restored.id, b.id);
      expect(restored.userId, b.userId);
      expect(restored.category, b.category);
      expect(restored.limitAmount, b.limitAmount);
      expect(restored.period, b.period);
      expect(restored.createdAt, b.createdAt);
    });
  });

  group('Budget.copyWith', () {
    test('replaces the specified field', () {
      final copy = _base().copyWith(limitAmount: 750.0);
      expect(copy.limitAmount, 750.0);
    });

    test('preserves unchanged fields', () {
      final original = _base();
      final copy = original.copyWith(period: BudgetPeriod.weekly);
      expect(copy.period, BudgetPeriod.weekly);
      expect(copy.id, original.id);
      expect(copy.category, original.category);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith with no arguments returns an equal instance', () {
      final original = _base();
      expect(original.copyWith(), equals(original));
    });

    test('can change the category', () {
      final copy = _base().copyWith(category: TransactionCategory.shopping);
      expect(copy.category, TransactionCategory.shopping);
    });
  });

  group('Budget equality', () {
    test('two instances with identical fields are equal', () {
      expect(_base(), equals(_base()));
    });

    test('instances differ when id differs', () {
      expect(_base(), isNot(equals(_base().copyWith(id: 'b2'))));
    });

    test('instances differ when limitAmount differs', () {
      expect(_base(), isNot(equals(_base().copyWith(limitAmount: 999.0))));
    });

    test('instances differ when period differs', () {
      expect(
        _base(),
        isNot(equals(_base().copyWith(period: BudgetPeriod.yearly))),
      );
    });
  });

  group('Budget.hashCode', () {
    test('equal instances have the same hashCode', () {
      expect(_base().hashCode, _base().hashCode);
    });

    test('different instances have different hashCodes (likely)', () {
      expect(_base().hashCode, isNot(_base().copyWith(id: 'x').hashCode));
    });
  });

  group('BudgetPeriod.fromName', () {
    test('parses weekly', () {
      expect(BudgetPeriod.fromName('weekly'), BudgetPeriod.weekly);
    });

    test('parses biweekly', () {
      expect(BudgetPeriod.fromName('biweekly'), BudgetPeriod.biweekly);
    });

    test('parses yearly', () {
      expect(BudgetPeriod.fromName('yearly'), BudgetPeriod.yearly);
    });

    test('falls back to monthly for unknown string', () {
      expect(BudgetPeriod.fromName('quarterly'), BudgetPeriod.monthly);
    });
  });
}
