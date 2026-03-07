/// Tests for TransactionProvider: loading states, error handling, list mutations.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Mock classes
// ──────────────────────────────────────────────────────────────────────────────

class MockTransactionService extends Mock implements TransactionService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ──────────────────────────────────────────────────────────────────────────────
// Fixtures
// ──────────────────────────────────────────────────────────────────────────────

Transaction _makeTx({
  String id = 't1',
  double amount = -50.0,
  String description = 'Lunch',
}) => Transaction(
  id: id,
  userId: 'u1',
  amount: amount,
  category: TransactionCategory.food,
  description: description,
  date: DateTime.utc(2026, 1, 15),
);

void main() {
  late MockTransactionService mockService;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(_makeTx());
  });

  setUp(() {
    mockService = MockTransactionService();
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

  TransactionProvider _makeProvider() =>
      TransactionProvider(apiClient: dummyApi, service: mockService);

  // ────────────────────────────────────────────────────────────────────────────
  // Initial state
  // ────────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('transactions is empty', () {
      expect(_makeProvider().transactions, isEmpty);
    });

    test('isLoading is false', () {
      expect(_makeProvider().isLoading, isFalse);
    });

    test('error is null', () {
      expect(_makeProvider().error, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // fetchTransactions
  // ────────────────────────────────────────────────────────────────────────────

  group('fetchTransactions', () {
    test('populates transactions list on success', () async {
      final txList = [_makeTx(id: 'a'), _makeTx(id: 'b')];
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenAnswer((_) async => txList);

      final provider = _makeProvider();
      await provider.fetchTransactions();

      expect(provider.transactions, hasLength(2));
      expect(provider.transactions.map((t) => t.id), containsAll(['a', 'b']));
    });

    test('isLoading transitions from true → false', () async {
      final calls = <bool>[];
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenAnswer((_) async => []);

      final provider = _makeProvider();
      provider.addListener(() => calls.add(provider.isLoading));
      await provider.fetchTransactions();

      // first notification: isLoading=true, last: isLoading=false
      expect(calls.first, isTrue);
      expect(calls.last, isFalse);
    });

    test('sets error and leaves list empty on failure', () async {
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenThrow(Exception('Network error'));

      final provider = _makeProvider();
      await provider.fetchTransactions();

      expect(provider.transactions, isEmpty);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Network error'));
    });

    test('isLoading is false after failure', () async {
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenThrow(Exception('fail'));

      final provider = _makeProvider();
      await provider.fetchTransactions();

      expect(provider.isLoading, isFalse);
    });

    test('forwards category filter to service', () async {
      when(
        () => mockService.fetchTransactions(category: TransactionCategory.food),
      ).thenAnswer((_) async => [_makeTx()]);

      await _makeProvider().fetchTransactions(
        category: TransactionCategory.food,
      );

      verify(
        () => mockService.fetchTransactions(category: TransactionCategory.food),
      ).called(1);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // addTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('addTransaction', () {
    test('inserts created transaction at index 0', () async {
      final created = _makeTx(id: 'new');
      when(
        () => mockService.createTransaction(any()),
      ).thenAnswer((_) async => created);

      final provider = _makeProvider();
      await provider.addTransaction(_makeTx());

      expect(provider.transactions.first.id, 'new');
    });

    test('prepends to an existing list', () async {
      // Seed list via fetchTransactions.
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenAnswer((_) async => [_makeTx(id: 'old')]);
      when(
        () => mockService.createTransaction(any()),
      ).thenAnswer((_) async => _makeTx(id: 'new'));

      final provider = _makeProvider();
      await provider.fetchTransactions();
      await provider.addTransaction(_makeTx());

      expect(provider.transactions.first.id, 'new');
      expect(provider.transactions[1].id, 'old');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.createTransaction(any()),
      ).thenThrow(Exception('Server error'));

      await expectLater(
        _makeProvider().addTransaction(_makeTx()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('updateTransaction', () {
    test('replaces matching transaction in list', () async {
      final original = _makeTx(id: 't1', amount: -50.0);
      final updated = _makeTx(id: 't1', amount: -99.0);

      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenAnswer((_) async => [original]);
      when(
        () => mockService.updateTransaction(any()),
      ).thenAnswer((_) async => updated);

      final provider = _makeProvider();
      await provider.fetchTransactions();
      await provider.updateTransaction(original);

      expect(provider.transactions.first.amount, -99.0);
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.updateTransaction(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().updateTransaction(_makeTx()),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('deleteTransaction', () {
    test('removes transaction from list by id', () async {
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenAnswer((_) async => [_makeTx(id: 't1'), _makeTx(id: 't2')]);
      when(() => mockService.deleteTransaction(any())).thenAnswer((_) async {});

      final provider = _makeProvider();
      await provider.fetchTransactions();
      await provider.deleteTransaction('t1');

      expect(provider.transactions, hasLength(1));
      expect(provider.transactions.first.id, 't2');
    });

    test('rethrows on failure', () async {
      when(
        () => mockService.deleteTransaction(any()),
      ).thenThrow(Exception('Not found'));

      await expectLater(
        _makeProvider().deleteTransaction('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // clearError
  // ────────────────────────────────────────────────────────────────────────────

  group('clearError', () {
    test('sets error to null', () async {
      when(
        () => mockService.fetchTransactions(category: any(named: 'category')),
      ).thenThrow(Exception('fail'));

      final provider = _makeProvider();
      await provider.fetchTransactions();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
