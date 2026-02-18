import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/app.dart';

void main() {
  testWidgets('SmartSpendApp renders home screen', (tester) async {
    await tester.pumpWidget(const SmartSpendApp());
    expect(find.text('SmartSpend'), findsOneWidget);
  });
}
