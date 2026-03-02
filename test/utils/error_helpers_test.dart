import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

void main() {
  group('formatError', () {
    test('strips Exception prefix', () {
      expect(formatError(Exception('Something failed')), 'Something failed');
    });

    test('returns plain string unchanged', () {
      expect(formatError('Network error'), 'Network error');
    });

    test('handles objects via toString', () {
      expect(formatError(42), '42');
    });
  });
}
