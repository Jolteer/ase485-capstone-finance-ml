/// Smoke test: LoginScreen renders key UI elements without any network calls.
///
/// Scoped to the login screen only so it never touches ApiClient, storage,
/// or any other provider that would require platform channels.
library;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/auth/login_screen.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  testWidgets('LoginScreen renders SmartSpend title and sign-in form', (
    tester,
  ) async {
    final storage = MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

    final api = ApiClient(
      // Never actually called — the test only renders, does not submit.
      client: MockClient((_) async => http.Response('', 200)),
      storage: storage,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(apiClient: api, userStorage: storage),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('SmartSpend'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('LoginScreen shows Email and Password fields', (tester) async {
    final storage = MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

    final api = ApiClient(
      client: MockClient((_) async => http.Response('', 200)),
      storage: storage,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(apiClient: api, userStorage: storage),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
  });

  testWidgets('LoginScreen has a Sign Up navigation link', (tester) async {
    final storage = MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

    final api = ApiClient(
      client: MockClient((_) async => http.Response('', 200)),
      storage: storage,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(apiClient: api, userStorage: storage),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Sign Up'), findsOneWidget);
  });
}
