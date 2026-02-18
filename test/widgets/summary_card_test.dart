import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';

void main() {
  testWidgets('SummaryCard displays title and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            title: 'Total Spent',
            value: '\$1,200.00',
            icon: Icons.attach_money,
          ),
        ),
      ),
    );

    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('\$1,200.00'), findsOneWidget);
  });
}
