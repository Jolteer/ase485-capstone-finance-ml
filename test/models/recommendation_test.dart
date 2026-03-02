import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';

void main() {
  group('Recommendation model', () {
    test('fromJson creates Recommendation correctly', () {
      final json = {
        'id': '1',
        'category': 'Food',
        'title': 'Reduce dining out',
        'description': 'Cook at home more often to save money.',
        'potential_savings': 150.0,
      };
      final r = Recommendation.fromJson(json);
      expect(r.id, '1');
      expect(r.category, 'Food');
      expect(r.title, 'Reduce dining out');
      expect(r.potentialSavings, 150.0);
    });

    test('toJson round-trips correctly', () {
      final r = Recommendation(
        id: '2',
        category: 'Transport',
        title: 'Use public transit',
        description: 'Switch to bus/train for daily commute.',
        potentialSavings: 200.0,
      );
      final restored = Recommendation.fromJson(r.toJson());
      expect(restored.id, r.id);
      expect(restored.category, r.category);
      expect(restored.potentialSavings, r.potentialSavings);
    });
  });
}
