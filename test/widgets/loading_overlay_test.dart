/// Widget tests for LoadingOverlay: child always visible, spinner shown/hidden with isLoading.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('LoadingOverlay', () {
    testWidgets('child is always rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LoadingOverlay(isLoading: false, child: Text('My Content')),
        ),
      );
      expect(find.text('My Content'), findsOneWidget);
    });

    testWidgets('child is rendered even while loading', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoadingOverlay(isLoading: true, child: Text('Underneath'))),
      );
      expect(find.text('Underneath'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const LoadingOverlay(isLoading: true, child: SizedBox())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides CircularProgressIndicator when isLoading is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const LoadingOverlay(isLoading: false, child: SizedBox())),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses a Stack so child and spinner coexist', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoadingOverlay(isLoading: true, child: Text('Behind'))),
      );
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.text('Behind'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no spinner after switching isLoading from true to false', (
      tester,
    ) async {
      bool loading = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    LoadingOverlay(
                      isLoading: loading,
                      child: const Text('Content'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => loading = false),
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Stop'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
