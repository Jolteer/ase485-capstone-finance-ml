import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

void main() {
  group('Transaction model', () {
    test('fromJson creates Transaction correctly', () {
      final json = {
        'id': '1',
        'user_id': 'u1',
        'amount': 42.50,
        'category': 'Food',
        'description': 'Lunch',
        'date': '2026-02-01T12:00:00.000Z',
      };
      final t = Transaction.fromJson(json);
      expect(t.amount, 42.50);
      expect(t.category, 'Food');
    });

    test('toJson round-trips correctly', () {
      final t = Transaction(
        id: '1',
        userId: 'u1',
        amount: 10.0,
        category: 'Bills',
        description: 'Electric',
        date: DateTime.utc(2026, 2, 1),
      );
      final restored = Transaction.fromJson(t.toJson());
      expect(restored.amount, t.amount);
      expect(restored.description, t.description);
    });
  });
}
