/// Tests for TransactionProvider: loading states, error handling, list mutations.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/repositories/transaction_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

Transaction makeTx({
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
  late MockTransactionRepository mockRepo;
  late ApiClient dummyApi;

  setUpAll(() {
    registerFallbackValue(makeTx());
  });

  setUp(() {
    mockRepo = MockTransactionRepository();
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

  TransactionProvider buildProvider() =>
      TransactionProvider(apiClient: dummyApi, repository: mockRepo);

  group('initial state', () {
    test(
      'transactions is empty',
      () => expect(buildProvider().transactions, isEmpty),
    );
    test(
      'isLoading is false',
      () => expect(buildProvider().isLoading, isFalse),
    );
    test('error is null', () => expect(buildProvider().error, isNull));
  });

  group('fetchTransactions', () {
    test('populates list on success', () async {
      when(
        () => mockRepo.fetch(category: any(named: 'category')),
      ).thenAnswer((_) async => [makeTx(id: 'a'), makeTx(id: 'b')]);

      final provider = buildProvider();
      await provider.fetchTransactions();

      expect(provider.transactions, hasLength(2));
    });

    test('sets error on failure', () async {
      when(
        () => mockRepo.fetch(category: any(named: 'category')),
      ).thenThrow(Exception('Network error'));

      final provider = buildProvider();
      await provider.fetchTransactions();

      expect(provider.transactions, isEmpty);
      expect(provider.error, contains('Network error'));
    });

    test('forwards category filter to repository', () async {
      when(
        () => mockRepo.fetch(category: TransactionCategory.food),
      ).thenAnswer((_) async => [makeTx()]);

      await buildProvider().fetchTransactions(
        category: TransactionCategory.food,
      );

      verify(
        () => mockRepo.fetch(category: TransactionCategory.food),
      ).called(1);
    });
  });

  group('addTransaction', () {
    test('inserts created tx at index 0', () async {
      when(
        () => mockRepo.create(any()),
      ).thenAnswer((_) async => makeTx(id: 'new'));

      final provider = buildProvider();
      await provider.addTransaction(makeTx());

      expect(provider.transactions.first.id, 'new');
    });

    test('rethrows on failure', () async {
      when(() => mockRepo.create(any())).thenThrow(Exception('Server error'));
      await expectLater(
        buildProvider().addTransaction(makeTx()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateTransaction', () {
    test('replaces matching transaction in list', () async {
      final original = makeTx(id: 't1', amount: -50.0);
      final updated = makeTx(id: 't1', amount: -99.0);

      when(
        () => mockRepo.fetch(category: any(named: 'category')),
      ).thenAnswer((_) async => [original]);
      when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

      final provider = buildProvider();
      await provider.fetchTransactions();
      await provider.updateTransaction(original);

      expect(provider.transactions.first.amount, -99.0);
    });
  });

  group('deleteTransaction', () {
    test('removes transaction from list by id', () async {
      when(
        () => mockRepo.fetch(category: any(named: 'category')),
      ).thenAnswer((_) async => [makeTx(id: 't1'), makeTx(id: 't2')]);
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      final provider = buildProvider();
      await provider.fetchTransactions();
      await provider.deleteTransaction('t1');

      expect(provider.transactions, hasLength(1));
      expect(provider.transactions.first.id, 't2');
    });
  });

  group('clearError', () {
    test('sets error to null', () async {
      when(
        () => mockRepo.fetch(category: any(named: 'category')),
      ).thenThrow(Exception('fail'));

      final provider = buildProvider();
      await provider.fetchTransactions();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
