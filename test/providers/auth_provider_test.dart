/// Tests for AuthProvider: login, register, logout, tryRestore, loading/error states.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/repositories/auth_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Mock classes
// ──────────────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

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
  late MockAuthRepository mockRepo;

  setUp(() {
    mockApi = MockApiClient();
    mockRepo = MockAuthRepository();
  });

  AuthProvider buildProvider() =>
      AuthProvider(apiClient: mockApi, repository: mockRepo);

  // ────────────────────────────────────────────────────────────────────────────
  // Initial state
  // ────────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('is not loading', () {
      expect(buildProvider().isLoading, isFalse);
    });
    test('is not authenticated', () {
      expect(buildProvider().isAuthenticated, isFalse);
    });
    test('has no current user', () {
      expect(buildProvider().currentUser, isNull);
    });
    test('has no error', () {
      expect(buildProvider().error, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // login
  // ────────────────────────────────────────────────────────────────────────────

  group('login', () {
    test('sets currentUser and isAuthenticated on success', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => AuthSession(token: 'tok', user: _kUser));

      final provider = buildProvider();
      await provider.login('test@example.com', 'password');

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser, _kUser);
      expect(provider.error, isNull);
    });

    test('sets error string and leaves user null on failure', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenThrow(Exception('Invalid credentials'));

      final provider = buildProvider();
      await provider.login('bad@e.com', 'wrong');

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Invalid credentials'));
    });

    test('isLoading is false after login completes', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => AuthSession(token: 'tok', user: _kUser));

      final provider = buildProvider();
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
        () => mockRepo.register(any(), any(), any()),
      ).thenAnswer((_) async => AuthSession(token: 'tok', user: _kUser));

      final provider = buildProvider();
      await provider.register('Test User', 'test@example.com', 'password');

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser, _kUser);
    });

    test('sets error on failure', () async {
      when(
        () => mockRepo.register(any(), any(), any()),
      ).thenThrow(Exception('Email already registered'));

      final provider = buildProvider();
      await provider.register('Name', 'dup@e.com', 'pw');

      expect(provider.error, isNotNull);
      expect(provider.error, contains('Email already registered'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // logout
  // ────────────────────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears currentUser and isAuthenticated', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenAnswer((_) async => AuthSession(token: 'tok', user: _kUser));
      when(() => mockRepo.clearSession()).thenAnswer((_) async {});

      final provider = buildProvider();
      await provider.login('u@e.com', 'pw');
      expect(provider.isAuthenticated, isTrue);

      provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
    });

    test('delegates to repository.clearSession', () async {
      when(() => mockRepo.clearSession()).thenAnswer((_) async {});
      buildProvider().logout();
      verify(() => mockRepo.clearSession()).called(1);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // tryRestore
  // ────────────────────────────────────────────────────────────────────────────

  group('tryRestore', () {
    test('restores user when repository returns one', () async {
      when(() => mockRepo.tryRestore()).thenAnswer((_) async => _kUser);

      final provider = buildProvider();
      await provider.tryRestore();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.email, 'test@example.com');
    });

    test('stays unauthenticated when repository returns null', () async {
      when(() => mockRepo.tryRestore()).thenAnswer((_) async => null);

      final provider = buildProvider();
      await provider.tryRestore();

      expect(provider.isAuthenticated, isFalse);
    });

    test('isRestoring is false after restore completes', () async {
      when(() => mockRepo.tryRestore()).thenAnswer((_) async => null);

      final provider = buildProvider();
      await provider.tryRestore();

      expect(provider.isRestoring, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // clearError
  // ────────────────────────────────────────────────────────────────────────────

  group('clearError', () {
    test('sets error to null', () async {
      when(
        () => mockRepo.login(any(), any()),
      ).thenThrow(Exception('Bad credentials'));

      final provider = buildProvider();
      await provider.login('u@e.com', 'wrong');
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
