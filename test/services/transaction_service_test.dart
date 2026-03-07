/// Tests for TransactionService: fetch (with/without category filter), create, update, delete.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _kTxJson = <String, dynamic>{
  'id': 't1',
  'user_id': 'u1',
  'amount': -50.0,
  'category': 'food',
  'description': 'Lunch',
  'date': '2026-01-15T12:00:00.000Z',
};

Transaction _fakeTx({String id = 't1'}) => Transaction(
  id: id,
  userId: 'u1',
  amount: -50.0,
  category: TransactionCategory.food,
  description: 'Lunch',
  date: DateTime.utc(2026, 1, 15),
);

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

  TransactionService _makeService(
    http.Response Function(http.Request) handler,
  ) {
    final api = ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
    return TransactionService(api);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // fetchTransactions
  // ────────────────────────────────────────────────────────────────────────────

  group('TransactionService.fetchTransactions', () {
    test('returns parsed list on 200', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode([_kTxJson]), 200),
      );

      final result = await svc.fetchTransactions();
      expect(result, hasLength(1));
      expect(result.first.id, 't1');
      expect(result.first.category, TransactionCategory.food);
      expect(result.first.amount, -50.0);
    });

    test('returns empty list when response array is empty', () async {
      final svc = _makeService((_) => http.Response('[]', 200));
      final result = await svc.fetchTransactions();
      expect(result, isEmpty);
    });

    test('sends category query param when filter provided', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode([_kTxJson]), 200);
      });

      await svc.fetchTransactions(category: TransactionCategory.food);
      expect(captured.url.queryParameters['category'], 'food');
    });

    test('omits category query param when no filter', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await svc.fetchTransactions();
      expect(captured.url.queryParameters.containsKey('category'), isFalse);
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );
      expect(() => svc.fetchTransactions(), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // createTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('TransactionService.createTransaction', () {
    test(
      'returns created transaction with server-assigned id on 201',
      () async {
        final createdJson = {..._kTxJson, 'id': 'server-id'};
        final svc = _makeService(
          (_) => http.Response(jsonEncode(createdJson), 201),
        );

        final result = await svc.createTransaction(_fakeTx());
        expect(result.id, 'server-id');
      },
    );

    test('strips id and user_id from request body', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kTxJson), 201);
      });

      await svc.createTransaction(_fakeTx(id: 'should-be-stripped'));
      final body = jsonDecode(captured.body) as Map;
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('user_id'), isFalse);
    });

    test('throws on non-201 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Bad request'}), 400),
      );
      expect(() => svc.createTransaction(_fakeTx()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('TransactionService.updateTransaction', () {
    test('returns updated transaction on 200', () async {
      final updatedJson = {..._kTxJson, 'amount': -75.0};
      final svc = _makeService(
        (_) => http.Response(jsonEncode(updatedJson), 200),
      );

      final result = await svc.updateTransaction(_fakeTx());
      expect(result.amount, -75.0);
    });

    test('sends PUT to /transactions/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kTxJson), 200);
      });

      await svc.updateTransaction(_fakeTx(id: 't42'));
      expect(captured.method, 'PUT');
      expect(captured.url.path, endsWith('/transactions/t42'));
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.updateTransaction(_fakeTx()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteTransaction
  // ────────────────────────────────────────────────────────────────────────────

  group('TransactionService.deleteTransaction', () {
    test('completes without error on 204', () async {
      final svc = _makeService((_) => http.Response('', 204));
      await expectLater(svc.deleteTransaction('t1'), completes);
    });

    test('sends DELETE to /transactions/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response('', 204);
      });

      await svc.deleteTransaction('tx-99');
      expect(captured.method, 'DELETE');
      expect(captured.url.path, endsWith('/transactions/tx-99'));
    });

    test('throws on non-204 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.deleteTransaction('missing'), throwsA(isA<Exception>()));
    });
  });
}
