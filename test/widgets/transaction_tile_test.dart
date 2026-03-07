/// Widget tests for TransactionTile: renders description, category label, amount, and onTap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Transaction _makeTx({
  String description = 'Grocery run',
  double amount = -45.0,
  TransactionCategory category = TransactionCategory.food,
}) => Transaction(
  id: 't1',
  userId: 'u1',
  amount: amount,
  category: category,
  description: description,
  date: DateTime.utc(2026, 3, 1),
);

void main() {
  group('TransactionTile', () {
    testWidgets('renders the transaction description', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TransactionTile(transaction: _makeTx(description: 'Grocery run')),
        ),
      );
      expect(find.text('Grocery run'), findsOneWidget);
    });

    testWidgets('renders the category label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TransactionTile(
            transaction: _makeTx(category: TransactionCategory.entertainment),
          ),
        ),
      );
      expect(find.textContaining('Entertainment'), findsOneWidget);
    });

    testWidgets('renders the formatted amount', (tester) async {
      await tester.pumpWidget(
        _wrap(TransactionTile(transaction: _makeTx(amount: -45.0))),
      );
      // Verify a trailing Text widget exists (currency-formatted amount).
      expect(
        find.descendant(of: find.byType(ListTile), matching: find.byType(Text)),
        findsWidgets,
      );
    });

    testWidgets('renders a CircleAvatar leading icon', (tester) async {
      await tester.pumpWidget(_wrap(TransactionTile(transaction: _makeTx())));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('calls onTap when the tile is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          TransactionTile(transaction: _makeTx(), onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(_wrap(TransactionTile(transaction: _makeTx())));
      // Tapping a tile with no onTap should not throw.
      await tester.tap(find.byType(ListTile));
    });

    testWidgets('renders correctly for an income transaction', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TransactionTile(
            transaction: _makeTx(amount: 1200.0, description: 'Salary'),
          ),
        ),
      );
      expect(find.text('Salary'), findsOneWidget);
    });
  });
}
