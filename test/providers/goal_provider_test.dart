/// Tests for GoalProvider: loading states, error handling, list mutations.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Mock classes
// ──────────────────────────────────────────────────────────────────────────────

class MockGoalService extends Mock implements GoalService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ──────────────────────────────────────────────────────────────────────────────
// Fixtures
// ──────────────────────────────────────────────────────────────────────────────

Goal _makeGoal({
  String id = 'g1',
  double target = 5000.0,
  double progress = 1000.0,
}) => Goal(
  id: id,
  userId: 'u1',
  targetAmount: target,
  targetDate: DateTime.utc(2027, 1, 1),
  description: 'Vacation fund',
  progress: progress,
  category: GoalCategory.vacation,
);

void main() {
  late MockGoalService mockService;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(_makeGoal());
  });

  setUp(() {
    mockService = MockGoalService();
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
    dummyApi = ApiClient(
      client: MockClient((_) async => http.Response('', 200)),
      storage: storage,
    );
  });

  GoalProvider _makeProvider() =>
      GoalProvider(apiClient: dummyApi, service: mockService);

  // ────────────────────────────────────────────────────────────────────────────
  // Initial state
  // ────────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('goals is empty', () => expect(_makeProvider().goals, isEmpty));
    test(
      'isLoading is false',
      () => expect(_makeProvider().isLoading, isFalse),
    );
    test('error is null', () => expect(_makeProvider().error, isNull));
  });

  // ────────────────────────────────────────────────────────────────────────────
  // fetchGoals
  // ────────────────────────────────────────────────────────────────────────────

  group('fetchGoals', () {
    test('populates goals on success', () async {
      when(
        () => mockService.fetchGoals(),
      ).thenAnswer((_) async => [_makeGoal(id: 'a'), _makeGoal(id: 'b')]);

      final provider = _makeProvider();
      await provider.fetchGoals();

      expect(provider.goals, hasLength(2));
      expect(provider.goals.map((g) => g.id), containsAll(['a', 'b']));
    });

    test('isLoading transitions true → false', () async {
      final calls = <bool>[];
      when(() => mockService.fetchGoals()).thenAnswer((_) async => []);

      final provider = _makeProvider();
      provider.addListener(() => calls.add(provider.isLoading));
      await provider.fetchGoals();

      expect(calls.first, isTrue);
      expect(calls.last, isFalse);
    });

    test('sets error and leaves list empty on failure', () async {
      when(() => mockService.fetchGoals()).thenThrow(Exception('No internet'));

      final provider = _makeProvider();
      await provider.fetchGoals();

      expect(provider.goals, isEmpty);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('No internet'));
    });

    test('isLoading is false after failure', () async {
      when(() => mockService.fetchGoals()).thenThrow(Exception('fail'));

      final provider = _makeProvider();
      await provider.fetchGoals();

      expect(provider.isLoading, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // addGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('addGoal', () {
    test('appends created goal to list', () async {
      when(
        () => mockService.createGoal(any()),
      ).thenAnswer((_) async => _makeGoal(id: 'new'));

      final provider = _makeProvider();
      await provider.addGoal(_makeGoal());

      expect(provider.goals.last.id, 'new');
    });

    test('appends after existing items', () async {
      when(
        () => mockService.fetchGoals(),
      ).thenAnswer((_) async => [_makeGoal(id: 'old')]);
      when(
        () => mockService.createGoal(any()),
      ).thenAnswer((_) async => _makeGoal(id: 'new'));

      final provider = _makeProvider();
      await provider.fetchGoals();
      await provider.addGoal(_makeGoal());

      expect(provider.goals[0].id, 'old');
      expect(provider.goals[1].id, 'new');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.createGoal(any()),
      ).thenThrow(Exception('Server error'));

      await expectLater(
        _makeProvider().addGoal(_makeGoal()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('updateGoal', () {
    test('replaces matching goal in list', () async {
      final original = _makeGoal(id: 'g1', progress: 1000.0);
      final updated = _makeGoal(id: 'g1', progress: 4000.0);

      when(() => mockService.fetchGoals()).thenAnswer((_) async => [original]);
      when(
        () => mockService.updateGoal(any()),
      ).thenAnswer((_) async => updated);

      final provider = _makeProvider();
      await provider.fetchGoals();
      await provider.updateGoal(original);

      expect(provider.goals.first.progress, 4000.0);
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.updateGoal(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().updateGoal(_makeGoal()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('deleteGoal', () {
    test('removes goal by id from list', () async {
      when(
        () => mockService.fetchGoals(),
      ).thenAnswer((_) async => [_makeGoal(id: 'g1'), _makeGoal(id: 'g2')]);
      when(() => mockService.deleteGoal(any())).thenAnswer((_) async {});

      final provider = _makeProvider();
      await provider.fetchGoals();
      await provider.deleteGoal('g1');

      expect(provider.goals, hasLength(1));
      expect(provider.goals.first.id, 'g2');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.deleteGoal(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().deleteGoal('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // clearError
  // ────────────────────────────────────────────────────────────────────────────

  group('clearError', () {
    test('sets error to null', () async {
      when(() => mockService.fetchGoals()).thenThrow(Exception('fail'));

      final provider = _makeProvider();
      await provider.fetchGoals();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
