/// Tests for AuthProvider: login, register, logout, tryRestore, loading/error states.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Mock classes
// ──────────────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

class MockAuthService extends Mock implements AuthService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ──────────────────────────────────────────────────────────────────────────────
// Fixtures
// ──────────────────────────────────────────────────────────────────────────────

final _kUser = User(
  id: 'u1',
  email: 'test@example.com',
  name: 'Test User',
  createdAt: DateTime.utc(2025, 1, 1),
);

void main() {
  late MockApiClient mockApi;
  late MockAuthService mockAuthService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockApi = MockApiClient();
    mockAuthService = MockAuthService();
    mockStorage = MockFlutterSecureStorage();

    // Void methods are handled automatically by mocktail; stub async storage ops.
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
  });

  AuthProvider _makeProvider() => AuthProvider(
    apiClient: mockApi,
    service: mockAuthService,
    userStorage: mockStorage,
  );

  // ────────────────────────────────────────────────────────────────────────────
  // Initial state
  // ────────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('is not loading', () {
      expect(_makeProvider().isLoading, isFalse);
    });

    test('is not authenticated', () {
      expect(_makeProvider().isAuthenticated, isFalse);
    });

    test('has no current user', () {
      expect(_makeProvider().currentUser, isNull);
    });

    test('has no error', () {
      expect(_makeProvider().error, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // login
  // ────────────────────────────────────────────────────────────────────────────

  group('login', () {
    test('sets currentUser and isAuthenticated on success', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      final provider = _makeProvider();
      await provider.login('test@example.com', 'password');

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser, _kUser);
      expect(provider.error, isNull);
    });

    test('calls setToken on the ApiClient after successful login', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => (token: 'my-jwt', user: _kUser));

      await _makeProvider().login('u@e.com', 'pw');

      verify(() => mockApi.setToken('my-jwt')).called(1);
    });

    test('persists user JSON to secure storage after login', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      await _makeProvider().login('u@e.com', 'pw');

      verify(
        () => mockStorage.write(
          key: 'auth_user',
          value: any(named: 'value'),
        ),
      ).called(1);
    });

    test('sets error string and leaves user null on failure', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenThrow(Exception('Invalid credentials'));

      final provider = _makeProvider();
      await provider.login('bad@e.com', 'wrong');

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Invalid credentials'));
    });

    test('isLoading is false after login completes', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      final provider = _makeProvider();
      await provider.login('u@e.com', 'pw');

      expect(provider.isLoading, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // register
  // ────────────────────────────────────────────────────────────────────────────

  group('register', () {
    test('sets currentUser and isAuthenticated on success', () async {
      when(
        () => mockAuthService.register(any(), any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      final provider = _makeProvider();
      await provider.register('Test User', 'test@example.com', 'password');

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser, _kUser);
    });

    test('sets error on failure', () async {
      when(
        () => mockAuthService.register(any(), any(), any()),
      ).thenThrow(Exception('Email already registered'));

      final provider = _makeProvider();
      await provider.register('Name', 'dup@e.com', 'pw');

      expect(provider.error, isNotNull);
      expect(provider.error, contains('Email already registered'));
    });

    test('isLoading is false after register completes', () async {
      when(
        () => mockAuthService.register(any(), any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      final provider = _makeProvider();
      await provider.register('Name', 'u@e.com', 'pw');

      expect(provider.isLoading, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // logout
  // ────────────────────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears currentUser and isAuthenticated', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => (token: 'tok', user: _kUser));

      final provider = _makeProvider();
      await provider.login('u@e.com', 'pw');
      expect(provider.isAuthenticated, isTrue);

      provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
    });

    test('calls AuthService.logout', () async {
      _makeProvider().logout();
      verify(() => mockAuthService.logout()).called(1);
    });

    test('deletes cached user from secure storage', () async {
      _makeProvider().logout();
      verify(() => mockStorage.delete(key: 'auth_user')).called(1);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // tryRestore
  // ────────────────────────────────────────────────────────────────────────────

  group('tryRestore', () {
    test('restores user when token and cached user JSON both exist', () async {
      when(() => mockApi.tryRestoreToken()).thenAnswer((_) async => true);
      when(() => mockStorage.read(key: 'auth_user')).thenAnswer(
        (_) async =>
            '{"id":"u1","email":"test@example.com",'
            '"name":"Test User","created_at":"2025-01-01T00:00:00.000Z"}',
      );

      final provider = _makeProvider();
      await provider.tryRestore();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.email, 'test@example.com');
    });

    test('clears session when token exists but no cached user JSON', () async {
      when(() => mockApi.tryRestoreToken()).thenAnswer((_) async => true);
      when(
        () => mockStorage.read(key: 'auth_user'),
      ).thenAnswer((_) async => null);

      final provider = _makeProvider();
      await provider.tryRestore();

      expect(provider.isAuthenticated, isFalse);
      verify(() => mockApi.setToken(null)).called(1);
    });

    test('stays unauthenticated when no token stored', () async {
      when(() => mockApi.tryRestoreToken()).thenAnswer((_) async => false);

      final provider = _makeProvider();
      await provider.tryRestore();

      expect(provider.isAuthenticated, isFalse);
    });

    test('isLoading is false after restore completes', () async {
      when(() => mockApi.tryRestoreToken()).thenAnswer((_) async => false);

      final provider = _makeProvider();
      await provider.tryRestore();

      expect(provider.isLoading, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // clearError
  // ────────────────────────────────────────────────────────────────────────────

  group('clearError', () {
    test('sets error to null', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenThrow(Exception('Bad credentials'));

      final provider = _makeProvider();
      await provider.login('u@e.com', 'wrong');
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
