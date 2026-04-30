/// Tests for ApiClient: headers, HTTP methods, token management, and ApiException parsing.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/core/api/api_exception.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

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
  });

  ApiClient buildApi(http.Response Function(http.Request) handler) {
    return ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Request headers
  // ────────────────────────────────────────────────────────────────────────────

  group('request headers', () {
    test('always sends Content-Type: application/json', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await api.get('/test');
      expect(captured.headers['Content-Type'], 'application/json');
    });

    test('includes Authorization header after setToken is called', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      api.setToken('test-jwt');
      await api.get('/test');
      expect(captured.headers['Authorization'], 'Bearer test-jwt');
    });

    test('omits Authorization header when no token has been set', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await api.get('/test');
      expect(captured.headers.containsKey('Authorization'), isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // HTTP method routing
  // ────────────────────────────────────────────────────────────────────────────

  group('HTTP methods', () {
    test('get sends GET to correct path', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await api.get('/transactions');
      expect(captured.method, 'GET');
      expect(captured.url.path, endsWith('/transactions'));
    });

    test('get appends query parameters', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await api.get('/transactions', queryParams: {'category': 'food'});
      expect(captured.url.queryParameters['category'], 'food');
    });

    test('post sends POST with JSON body', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('{}', 201);
      });

      await api.post('/items', body: {'name': 'coffee', 'amount': 5.0});
      expect(captured.method, 'POST');
      final decoded = jsonDecode(captured.body) as Map;
      expect(decoded['name'], 'coffee');
      expect(decoded['amount'], 5.0);
    });

    test('put sends PUT with JSON body', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('{}', 200);
      });

      await api.put('/items/1', body: {'amount': 10.0});
      expect(captured.method, 'PUT');
      expect(jsonDecode(captured.body)['amount'], 10.0);
    });

    test('delete sends DELETE', () async {
      late http.Request captured;
      final api = buildApi((req) {
        captured = req;
        return http.Response('', 204);
      });

      await api.delete('/items/42');
      expect(captured.method, 'DELETE');
      expect(captured.url.path, endsWith('/items/42'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Token management
  // ────────────────────────────────────────────────────────────────────────────

  group('setToken', () {
    test('writes token to secure storage', () async {
      final api = buildApi((_) => http.Response('', 200));
      api.setToken('my-token');
      verify(
        () => storage.write(key: 'auth_token', value: 'my-token'),
      ).called(1);
    });

    test('deletes token from secure storage when null', () async {
      final api = buildApi((_) => http.Response('', 200));
      api.setToken(null);
      verify(() => storage.delete(key: 'auth_token')).called(1);
    });
  });

  group('tryRestoreToken', () {
    test('returns true and restores token when one is stored', () async {
      when(
        () => storage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'stored-token');
      final api = buildApi((_) => http.Response('', 200));

      expect(await api.tryRestoreToken(), isTrue);
    });

    test('returns false when no token is stored', () async {
      when(() => storage.read(key: 'auth_token')).thenAnswer((_) async => null);
      final api = buildApi((_) => http.Response('', 200));

      expect(await api.tryRestoreToken(), isFalse);
    });

    test('subsequent GET includes the restored token', () async {
      when(
        () => storage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'restored-token');
      late http.Request captured;
      final api = ApiClient(
        client: MockClient((req) async {
          captured = req;
          return http.Response('[]', 200);
        }),
        storage: storage,
      );

      await api.tryRestoreToken();
      await api.get('/me');
      expect(captured.headers['Authorization'], 'Bearer restored-token');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // ApiException parsing
  // ────────────────────────────────────────────────────────────────────────────

  group('ApiException.fromResponse', () {
    test('joins FastAPI validation list msg fields', () {
      final res = http.Response(
        jsonEncode({
          'detail': [
            {'msg': 'field required'},
            {'msg': 'value is not a valid email'},
          ],
        }),
        422,
      );
      expect(
        ApiException.fromResponse(res).message,
        'field required; value is not a valid email',
      );
    });

    test('returns the detail string', () {
      final res = http.Response(jsonEncode({'detail': 'Not found'}), 404);
      expect(ApiException.fromResponse(res).message, 'Not found');
    });

    test('returns the message string', () {
      final res = http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
      expect(ApiException.fromResponse(res).message, 'Unauthorized');
    });

    test('returns the error string', () {
      final res = http.Response(jsonEncode({'error': 'Server error'}), 500);
      expect(ApiException.fromResponse(res).message, 'Server error');
    });

    test('falls back to generic message with status code on invalid JSON', () {
      final res = http.Response('not valid json', 503);
      expect(ApiException.fromResponse(res).message, 'Request failed (503)');
    });

    test('falls back to validation message when detail list has no msg', () {
      final res = http.Response(
        jsonEncode({
          'detail': [{}],
        }),
        422,
      );
      expect(ApiException.fromResponse(res).message, 'Validation error (422)');
    });

    test('prefers detail over message when both are present', () {
      final res = http.Response(
        jsonEncode({'detail': 'Conflict', 'message': 'ignored'}),
        409,
      );
      expect(ApiException.fromResponse(res).message, 'Conflict');
    });

    test('exposes status code helpers', () {
      final res = http.Response(jsonEncode({'detail': 'nope'}), 401);
      final exc = ApiException.fromResponse(res);
      expect(exc.statusCode, 401);
      expect(exc.isUnauthorized, isTrue);
      expect(exc.isNotFound, isFalse);
    });
  });
}
