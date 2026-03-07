/// Tests for Transaction: fromJson, toJson, copyWith, equality, hashCode, computed props, edge cases.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';

Transaction _base() => Transaction(
  id: 't1',
  userId: 'u1',
  amount: -50.0,
  category: TransactionCategory.food,
  description: 'Lunch',
  date: DateTime.utc(2026, 2, 1),
);

void main() {
  group('Transaction.fromJson', () {
    test('maps all fields correctly', () {
      final json = {
        'id': '1',
        'user_id': 'u1',
        'amount': 42.50,
        'category': 'Food',
        'description': 'Lunch',
        'date': '2026-02-01T12:00:00.000Z',
      };
      final t = Transaction.fromJson(json);
      expect(t.id, '1');
      expect(t.userId, 'u1');
      expect(t.amount, 42.50);
      expect(t.category, TransactionCategory.food);
      expect(t.description, 'Lunch');
    });

    test('parses category case-insensitively', () {
      final t = Transaction.fromJson({
        'id': '1',
        'user_id': 'u1',
        'amount': -10.0,
        'category': 'ENTERTAINMENT',
        'description': 'Movie',
        'date': '2026-01-01T00:00:00.000Z',
      });
      expect(t.category, TransactionCategory.entertainment);
    });

    test('falls back to TransactionCategory.other for unknown category', () {
      final t = Transaction.fromJson({
        'id': '1',
        'user_id': 'u1',
        'amount': -5.0,
        'category': 'mystery_category',
        'description': 'Unknown',
        'date': '2026-01-01T00:00:00.000Z',
      });
      expect(t.category, TransactionCategory.other);
    });

    test('throws ArgumentError when amount is zero', () {
      expect(
        () => Transaction.fromJson({
          'id': '1',
          'user_id': 'u1',
          'amount': 0,
          'category': 'food',
          'description': 'Zero',
          'date': '2026-01-01T00:00:00.000Z',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when description is empty', () {
      expect(
        () => Transaction.fromJson({
          'id': '1',
          'user_id': 'u1',
          'amount': -10.0,
          'category': 'food',
          'description': '',
          'date': '2026-01-01T00:00:00.000Z',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Transaction.toJson round-trip', () {
    test('round-trips all fields through toJson/fromJson', () {
      final t = Transaction(
        id: '1',
        userId: 'u1',
        amount: 10.0,
        category: TransactionCategory.bills,
        description: 'Electric',
        date: DateTime.utc(2026, 2, 1),
      );
      final restored = Transaction.fromJson(t.toJson());
      expect(restored.id, t.id);
      expect(restored.userId, t.userId);
      expect(restored.amount, t.amount);
      expect(restored.category, t.category);
      expect(restored.description, t.description);
      expect(restored.date, t.date);
    });
  });

  group('Transaction.copyWith', () {
    test('returns a new instance with the specified field replaced', () {
      final original = _base();
      final copy = original.copyWith(description: 'Dinner');
      expect(copy.description, 'Dinner');
      expect(copy.id, original.id);
    });

    test('preserves unchanged fields', () {
      final original = _base();
      final copy = original.copyWith(amount: -99.0);
      expect(copy.amount, -99.0);
      expect(copy.category, original.category);
      expect(copy.date, original.date);
      expect(copy.userId, original.userId);
    });

    test('copyWith with no arguments returns an equal instance', () {
      final original = _base();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('can change the category', () {
      final copy = _base().copyWith(category: TransactionCategory.shopping);
      expect(copy.category, TransactionCategory.shopping);
    });
  });

  group('Transaction equality', () {
    test('two instances with identical fields are equal', () {
      final a = _base();
      final b = _base();
      expect(a, equals(b));
    });

    test('instances differ when id differs', () {
      final a = _base();
      final b = a.copyWith(id: 't2');
      expect(a, isNot(equals(b)));
    });

    test('instances differ when amount differs', () {
      final a = _base();
      final b = a.copyWith(amount: -99.0);
      expect(a, isNot(equals(b)));
    });

    test('instances differ when description differs', () {
      final a = _base();
      final b = a.copyWith(description: 'Dinner');
      expect(a, isNot(equals(b)));
    });
  });

  group('Transaction.hashCode', () {
    test('equal instances have equal hashCodes', () {
      expect(_base().hashCode, _base().hashCode);
    });

    test('different instances have different hashCodes (likely)', () {
      final a = _base();
      final b = a.copyWith(id: 'other');
      expect(a.hashCode, isNot(b.hashCode));
    });
  });

  group('Transaction computed properties', () {
    test('isExpense is true for negative amounts', () {
      expect(_base().isExpense, isTrue);
    });

    test('isIncome is true for positive amounts', () {
      expect(_base().copyWith(amount: 100.0).isIncome, isTrue);
    });

    test('absAmount always returns a positive value', () {
      expect(_base().absAmount, 50.0);
    });

    test('absAmount equals amount for income', () {
      final income = _base().copyWith(amount: 75.0);
      expect(income.absAmount, 75.0);
    });
  });

  group('TransactionCategory.fromName', () {
    test('resolves enum name string', () {
      expect(TransactionCategory.fromName('food'), TransactionCategory.food);
    });

    test('resolves display label string', () {
      expect(
        TransactionCategory.fromName('Healthcare'),
        TransactionCategory.healthcare,
      );
    });

    test('falls back to other for unknown string', () {
      expect(
        TransactionCategory.fromName('unicorn'),
        TransactionCategory.other,
      );
    });
  });
}
