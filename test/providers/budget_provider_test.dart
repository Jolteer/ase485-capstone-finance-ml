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
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Mock classes
// ──────────────────────────────────────────────────────────────────────────────

class MockBudgetService extends Mock implements BudgetService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ──────────────────────────────────────────────────────────────────────────────
// Fixtures
// ──────────────────────────────────────────────────────────────────────────────

Budget _makeBudget({String id = 'b1', double limit = 500.0}) => Budget(
  id: id,
  userId: 'u1',
  category: TransactionCategory.food,
  limitAmount: limit,
  period: BudgetPeriod.monthly,
  createdAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late MockBudgetService mockService;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(_makeBudget());
  });

  setUp(() {
    mockService = MockBudgetService();
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

  BudgetProvider _makeProvider() =>
      BudgetProvider(apiClient: dummyApi, service: mockService);

  // ────────────────────────────────────────────────────────────────────────────
  // Initial state
  // ────────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('budgets is empty', () => expect(_makeProvider().budgets, isEmpty));
    test(
      'isLoading is false',
      () => expect(_makeProvider().isLoading, isFalse),
    );
    test('error is null', () => expect(_makeProvider().error, isNull));
  });

  // ────────────────────────────────────────────────────────────────────────────
  // fetchBudgets
  // ────────────────────────────────────────────────────────────────────────────

  group('fetchBudgets', () {
    test('populates budgets on success', () async {
      when(
        () => mockService.fetchBudgets(),
      ).thenAnswer((_) async => [_makeBudget(id: 'a'), _makeBudget(id: 'b')]);

      final provider = _makeProvider();
      await provider.fetchBudgets();

      expect(provider.budgets, hasLength(2));
    });

    test('isLoading transitions true → false', () async {
      final calls = <bool>[];
      when(() => mockService.fetchBudgets()).thenAnswer((_) async => []);

      final provider = _makeProvider();
      provider.addListener(() => calls.add(provider.isLoading));
      await provider.fetchBudgets();

      expect(calls.first, isTrue);
      expect(calls.last, isFalse);
    });

    test('sets error and leaves list empty on failure', () async {
      when(() => mockService.fetchBudgets()).thenThrow(Exception('Offline'));

      final provider = _makeProvider();
      await provider.fetchBudgets();

      expect(provider.budgets, isEmpty);
      expect(provider.error, contains('Offline'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // addBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('addBudget', () {
    test('inserts created budget at index 0', () async {
      when(
        () => mockService.createBudget(any()),
      ).thenAnswer((_) async => _makeBudget(id: 'new'));

      final provider = _makeProvider();
      await provider.addBudget(_makeBudget());

      expect(provider.budgets.first.id, 'new');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.createBudget(any()),
      ).thenThrow(Exception('Server error'));

      await expectLater(
        _makeProvider().addBudget(_makeBudget()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('updateBudget', () {
    test('replaces matching budget in list', () async {
      final original = _makeBudget(id: 'b1', limit: 500.0);
      final updated = _makeBudget(id: 'b1', limit: 999.0);

      when(
        () => mockService.fetchBudgets(),
      ).thenAnswer((_) async => [original]);
      when(
        () => mockService.updateBudget(any()),
      ).thenAnswer((_) async => updated);

      final provider = _makeProvider();
      await provider.fetchBudgets();
      await provider.updateBudget(original);

      expect(provider.budgets.first.limitAmount, 999.0);
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.updateBudget(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().updateBudget(_makeBudget()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('deleteBudget', () {
    test('removes budget from list', () async {
      when(
        () => mockService.fetchBudgets(),
      ).thenAnswer((_) async => [_makeBudget(id: 'b1'), _makeBudget(id: 'b2')]);
      when(() => mockService.deleteBudget(any())).thenAnswer((_) async {});

      final provider = _makeProvider();
      await provider.fetchBudgets();
      await provider.deleteBudget('b1');

      expect(provider.budgets, hasLength(1));
      expect(provider.budgets.first.id, 'b2');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.deleteBudget(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().deleteBudget('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // clearError
  // ────────────────────────────────────────────────────────────────────────────

  group('clearError', () {
    test('sets error to null', () async {
      when(() => mockService.fetchBudgets()).thenThrow(Exception('fail'));

      final provider = _makeProvider();
      await provider.fetchBudgets();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
