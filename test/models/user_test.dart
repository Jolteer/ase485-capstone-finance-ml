import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';

void main() {
  group('User model', () {
    test('fromJson creates User correctly', () {
      final json = {
        'id': '1',
        'email': 'test@example.com',
        'name': 'Test User',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final user = User.fromJson(json);
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
    });

    test('toJson round-trips correctly', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.utc(2026),
      );
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
    });
  });
}
