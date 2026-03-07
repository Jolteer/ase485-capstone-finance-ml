/// Widget tests for SummaryCard: title, value, icon, and optional color.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SummaryCard', () {
    testWidgets('displays the title text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Total Spent',
            value: r'$1,200.00',
            icon: Icons.attach_money,
          ),
        ),
      );
      expect(find.text('Total Spent'), findsOneWidget);
    });

    testWidgets('displays the value text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Balance',
            value: r'$4,250.00',
            icon: Icons.account_balance_wallet,
          ),
        ),
      );
      expect(find.text(r'$4,250.00'), findsOneWidget);
    });

    testWidgets('renders the icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Income',
            value: r'$500.00',
            icon: Icons.arrow_downward,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('renders inside a Card widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Savings',
            value: r'$200.00',
            icon: Icons.savings,
          ),
        ),
      );
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('accepts an optional color prop without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Spent',
            value: r'$100.00',
            icon: Icons.money_off,
            color: Colors.red,
          ),
        ),
      );
      expect(find.text('Spent'), findsOneWidget);
    });

    testWidgets('displays both title and value together', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SummaryCard(
            title: 'Net',
            value: '-\$50.00',
            icon: Icons.trending_down,
          ),
        ),
      );
      expect(find.text('Net'), findsOneWidget);
      expect(find.text('-\$50.00'), findsOneWidget);
    });
  });
}
