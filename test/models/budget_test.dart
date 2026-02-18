import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';

void main() {
  group('Budget model', () {
    test('fromJson creates Budget correctly', () {
      final json = {
        'id': '1',
        'user_id': 'u1',
        'category': 'Food',
        'limit_amount': 500.0,
        'period': 'monthly',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final b = Budget.fromJson(json);
      expect(b.category, 'Food');
      expect(b.limitAmount, 500.0);
      expect(b.period, 'monthly');
    });
  });
}
