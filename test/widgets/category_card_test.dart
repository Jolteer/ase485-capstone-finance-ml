/// Widget tests for CategoryCard: category label, spent/limit text, progress bar,
/// over-budget styling, zero-limit guard, and onTap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/widgets/category_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CategoryCard', () {
    testWidgets('renders the category label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.food,
            spent: 200.0,
            limit: 500.0,
          ),
        ),
      );
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('renders a LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.entertainment,
            spent: 50.0,
            limit: 200.0,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders without error when limit is zero (division guard)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.bills,
            spent: 100.0,
            limit: 0.0,
          ),
        ),
      );
      // Progress bar value should be 0 — no division-by-zero crash.
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.0);
    });

    testWidgets('shows progress bar at ~0 when not yet spent', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.shopping,
            spent: 0.0,
            limit: 300.0,
          ),
        ),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, closeTo(0.0, 0.001));
    });

    testWidgets('clamps progress bar to 1.0 when over budget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.healthcare,
            spent: 600.0,
            limit: 500.0,
          ),
        ),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 1.0);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.food,
            spent: 100.0,
            limit: 500.0,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('accepts a custom icon without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CategoryCard(
            category: TransactionCategory.education,
            spent: 40.0,
            limit: 150.0,
            icon: Icons.star,
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
