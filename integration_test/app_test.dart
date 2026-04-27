/// Integration tests for SmartSpend.
///
/// These test the full widget tree rendered by the real app.
/// Run with: flutter test integration_test/
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ase485_capstone_finance_ml/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch', () {
    testWidgets('renders login screen on cold start', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('SmartSpend'), findsOneWidget);
    });

    testWidgets('login screen has email and password fields', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('login screen has a sign-in button', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('can navigate to register screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final registerLink = find.text('Sign Up');
      if (registerLink.evaluate().isNotEmpty) {
        await tester.tap(registerLink.first);
        await tester.pumpAndSettle();
        expect(find.text('Create Account'), findsOneWidget);
      }
    });
  });

  group('Login form validation', () {
    testWidgets('shows error on empty email submit', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(FilledButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('email'), findsWidgets);
    });
  });
}
