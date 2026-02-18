import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });

    test('email rejects invalid format', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('email accepts valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('password rejects short input', () {
      expect(Validators.password('abc'), isNotNull);
    });

    test('password accepts 8+ chars', () {
      expect(Validators.password('password123'), isNull);
    });

    test('amount rejects non-numeric', () {
      expect(Validators.amount('abc'), isNotNull);
    });

    test('amount accepts valid number', () {
      expect(Validators.amount('42.50'), isNull);
    });
  });
}
