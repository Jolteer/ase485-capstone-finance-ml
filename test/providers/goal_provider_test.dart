/// Tests for GoalProvider: loading states, error handling, list mutations.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/repositories/goal_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class MockGoalRepository extends Mock implements GoalRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

Goal makeGoal({
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
  late MockGoalRepository mockRepo;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(makeGoal());
  });

  setUp(() {
    mockRepo = MockGoalRepository();
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

  GoalProvider buildProvider() =>
      GoalProvider(apiClient: dummyApi, repository: mockRepo);

  group('initial state', () {
    test('goals is empty', () => expect(buildProvider().goals, isEmpty));
    test(
      'isLoading is false',
      () => expect(buildProvider().isLoading, isFalse),
    );
    test('error is null', () => expect(buildProvider().error, isNull));
  });

  group('fetchGoals', () {
    test('populates goals on success', () async {
      when(
        () => mockRepo.fetch(),
      ).thenAnswer((_) async => [makeGoal(id: 'a'), makeGoal(id: 'b')]);

      final provider = buildProvider();
      await provider.fetchGoals();

      expect(provider.goals, hasLength(2));
    });

    test('sets error and leaves list empty on failure', () async {
      when(() => mockRepo.fetch()).thenThrow(Exception('No internet'));

      final provider = buildProvider();
      await provider.fetchGoals();

      expect(provider.goals, isEmpty);
      expect(provider.error, contains('No internet'));
    });
  });

  group('addGoal', () {
    test('appends created goal to list', () async {
      when(
        () => mockRepo.create(any()),
      ).thenAnswer((_) async => makeGoal(id: 'new'));

      final provider = buildProvider();
      await provider.addGoal(makeGoal());

      expect(provider.goals.last.id, 'new');
    });
  });

  group('updateGoal', () {
    test('replaces matching goal in list', () async {
      final original = makeGoal(id: 'g1', progress: 1000.0);
      final updated = makeGoal(id: 'g1', progress: 4000.0);

      when(() => mockRepo.fetch()).thenAnswer((_) async => [original]);
      when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

      final provider = buildProvider();
      await provider.fetchGoals();
      await provider.updateGoal(original);

      expect(provider.goals.first.progress, 4000.0);
    });
  });

  group('deleteGoal', () {
    test('removes goal by id from list', () async {
      when(
        () => mockRepo.fetch(),
      ).thenAnswer((_) async => [makeGoal(id: 'g1'), makeGoal(id: 'g2')]);
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      final provider = buildProvider();
      await provider.fetchGoals();
      await provider.deleteGoal('g1');

      expect(provider.goals, hasLength(1));
      expect(provider.goals.first.id, 'g2');
    });
  });

  group('clearError', () {
    test('sets error to null', () async {
      when(() => mockRepo.fetch()).thenThrow(Exception('fail'));

      final provider = buildProvider();
      await provider.fetchGoals();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
