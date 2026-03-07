/// Tests for AuthService: register, login, logout via mock HTTP responses.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _kUserJson = <String, dynamic>{
  'id': 'u1',
  'email': 'test@example.com',
  'name': 'Test User',
  'created_at': '2025-01-01T00:00:00.000Z',
};

void main() {
  late MockFlutterSecureStorage storage;

  setUp(() {
    storage = MockFlutterSecureStorage();
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
  });

  AuthService _makeService(http.Response Function(http.Request) handler) {
    final api = ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
    return AuthService(api);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // register
  // ────────────────────────────────────────────────────────────────────────────

  group('AuthService.register', () {
    test('returns (token, user) record on 201', () async {
      final svc = _makeService(
        (_) => http.Response(
          jsonEncode({'token': 'tok-123', 'user': _kUserJson}),
          201,
        ),
      );

      final result = await svc.register(
        'Test User',
        'test@example.com',
        'pw123',
      );
      expect(result.token, 'tok-123');
      expect(result.user.email, 'test@example.com');
      expect(result.user.name, 'Test User');
      expect(result.user.id, 'u1');
    });

    test('throws Exception on 400', () async {
      final svc = _makeService(
        (_) => http.Response(
          jsonEncode({'detail': 'Email already registered'}),
          400,
        ),
      );

      expect(
        () => svc.register('Test', 'dup@example.com', 'pw'),
        throwsA(isA<Exception>()),
      );
    });

    test('error message includes detail from response body', () async {
      final svc = _makeService(
        (_) => http.Response(
          jsonEncode({'detail': 'Email already registered'}),
          409,
        ),
      );

      await expectLater(
        svc.register('Test', 'dup@example.com', 'pw'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Email already registered'),
          ),
        ),
      );
    });

    test('sends name, email, and password in POST body', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(
          jsonEncode({'token': 'tok', 'user': _kUserJson}),
          201,
        );
      });

      await svc.register('Alice', 'alice@example.com', 'secret');
      final body = jsonDecode(captured.body) as Map;
      expect(body['name'], 'Alice');
      expect(body['email'], 'alice@example.com');
      expect(body['password'], 'secret');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // login
  // ────────────────────────────────────────────────────────────────────────────

  group('AuthService.login', () {
    test('returns (token, user) record on 200', () async {
      final svc = _makeService(
        (_) => http.Response(
          jsonEncode({'token': 'tok-456', 'user': _kUserJson}),
          200,
        ),
      );

      final result = await svc.login('test@example.com', 'password123');
      expect(result.token, 'tok-456');
      expect(result.user.id, 'u1');
    });

    test('throws Exception on 401', () async {
      final svc = _makeService(
        (_) =>
            http.Response(jsonEncode({'detail': 'Invalid credentials'}), 401),
      );

      expect(
        () => svc.login('bad@example.com', 'wrongpw'),
        throwsA(isA<Exception>()),
      );
    });

    test('error message includes detail from response body', () async {
      final svc = _makeService(
        (_) =>
            http.Response(jsonEncode({'detail': 'Invalid credentials'}), 401),
      );

      await expectLater(
        svc.login('bad@example.com', 'wrongpw'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Invalid credentials'),
          ),
        ),
      );
    });

    test('sends email and password in POST body', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(
          jsonEncode({'token': 'tok', 'user': _kUserJson}),
          200,
        );
      });

      await svc.login('user@example.com', 'mypassword');
      final body = jsonDecode(captured.body) as Map;
      expect(body['email'], 'user@example.com');
      expect(body['password'], 'mypassword');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // logout
  // ────────────────────────────────────────────────────────────────────────────

  group('AuthService.logout', () {
    test('completes without throwing', () {
      final svc = _makeService((_) => http.Response('', 200));
      expect(() => svc.logout(), returnsNormally);
    });

    test(
      'clears token so subsequent requests omit Authorization header',
      () async {
        late http.Request captured;
        bool firstRequest = true;
        final svc = _makeService((req) {
          if (firstRequest) {
            firstRequest = false;
            return http.Response(
              jsonEncode({'token': 'tok', 'user': _kUserJson}),
              200,
            );
          }
          captured = req;
          return http.Response('[]', 200);
        });

        // Log in to set the token.
        final api = ApiClient(
          client: MockClient((req) async {
            if (req.url.path.contains('login')) {
              return http.Response(
                jsonEncode({'token': 'live-token', 'user': _kUserJson}),
                200,
              );
            }
            captured = req;
            return http.Response('[]', 200);
          }),
          storage: storage,
        );
        final authSvc = AuthService(api);
        await authSvc.login('u@u.com', 'pw');
        api.setToken('live-token');

        // Log out and fire a request; Authorization should be absent.
        authSvc.logout();
        await api.get('/test');
        expect(captured.headers.containsKey('Authorization'), isFalse);
      },
    );
  });
}
