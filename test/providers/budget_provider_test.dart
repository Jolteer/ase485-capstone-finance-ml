/// Tests for BudgetProvider: loading states, error handling, list mutations.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/repositories/budget_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

Budget makeBudget({String id = 'b1', double limit = 500.0}) => Budget(
  id: id,
  userId: 'u1',
  category: TransactionCategory.food,
  limitAmount: limit,
  period: BudgetPeriod.monthly,
  createdAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late MockBudgetRepository mockRepo;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(makeBudget());
  });

  setUp(() {
    mockRepo = MockBudgetRepository();
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

  BudgetProvider buildProvider() =>
      BudgetProvider(apiClient: dummyApi, repository: mockRepo);

  group('initial state', () {
    test('budgets is empty', () => expect(buildProvider().budgets, isEmpty));
    test(
      'isLoading is false',
      () => expect(buildProvider().isLoading, isFalse),
    );
    test('error is null', () => expect(buildProvider().error, isNull));
  });

  group('fetchBudgets', () {
    test('populates budgets on success', () async {
      when(
        () => mockRepo.fetch(),
      ).thenAnswer((_) async => [makeBudget(id: 'a'), makeBudget(id: 'b')]);

      final provider = buildProvider();
      await provider.fetchBudgets();

      expect(provider.budgets, hasLength(2));
    });

    test('sets error and leaves list empty on failure', () async {
      when(() => mockRepo.fetch()).thenThrow(Exception('Offline'));

      final provider = buildProvider();
      await provider.fetchBudgets();

      expect(provider.budgets, isEmpty);
      expect(provider.error, contains('Offline'));
    });
  });

  group('addBudget', () {
    test('inserts created budget at index 0', () async {
      when(
        () => mockRepo.create(any()),
      ).thenAnswer((_) async => makeBudget(id: 'new'));

      final provider = buildProvider();
      await provider.addBudget(makeBudget());

      expect(provider.budgets.first.id, 'new');
    });

    test('rethrows on failure', () async {
      when(() => mockRepo.create(any())).thenThrow(Exception('Server error'));

      await expectLater(
        buildProvider().addBudget(makeBudget()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateBudget', () {
    test('replaces matching budget in list', () async {
      final original = makeBudget(id: 'b1', limit: 500.0);
      final updated = makeBudget(id: 'b1', limit: 999.0);

      when(() => mockRepo.fetch()).thenAnswer((_) async => [original]);
      when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

      final provider = buildProvider();
      await provider.fetchBudgets();
      await provider.updateBudget(original);

      expect(provider.budgets.first.limitAmount, 999.0);
    });
  });

  group('deleteBudget', () {
    test('removes budget from list', () async {
      when(
        () => mockRepo.fetch(),
      ).thenAnswer((_) async => [makeBudget(id: 'b1'), makeBudget(id: 'b2')]);
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      final provider = buildProvider();
      await provider.fetchBudgets();
      await provider.deleteBudget('b1');

      expect(provider.budgets, hasLength(1));
      expect(provider.budgets.first.id, 'b2');
    });
  });

  group('clearError', () {
    test('sets error to null', () async {
      when(() => mockRepo.fetch()).thenThrow(Exception('fail'));

      final provider = buildProvider();
      await provider.fetchBudgets();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
