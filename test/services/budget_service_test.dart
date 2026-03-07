/// Tests for BudgetService: fetch, create, update, delete.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _kBudgetJson = <String, dynamic>{
  'id': 'b1',
  'user_id': 'u1',
  'category': 'food',
  'limit_amount': 500.0,
  'period': 'monthly',
  'created_at': '2026-01-01T00:00:00.000Z',
};

Budget _fakeBudget({String id = 'b1'}) => Budget(
  id: id,
  userId: 'u1',
  category: TransactionCategory.food,
  limitAmount: 500.0,
  period: BudgetPeriod.monthly,
  createdAt: DateTime.utc(2026, 1, 1),
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

  BudgetService _makeService(http.Response Function(http.Request) handler) {
    final api = ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
    return BudgetService(api);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // fetchBudgets
  // ────────────────────────────────────────────────────────────────────────────

  group('BudgetService.fetchBudgets', () {
    test('returns parsed list on 200', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode([_kBudgetJson]), 200),
      );

      final result = await svc.fetchBudgets();
      expect(result, hasLength(1));
      expect(result.first.id, 'b1');
      expect(result.first.limitAmount, 500.0);
      expect(result.first.period, BudgetPeriod.monthly);
    });

    test('returns empty list when response array is empty', () async {
      final svc = _makeService((_) => http.Response('[]', 200));
      expect(await svc.fetchBudgets(), isEmpty);
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );
      expect(() => svc.fetchBudgets(), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // createBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('BudgetService.createBudget', () {
    test('returns created budget with server id on 201', () async {
      final createdJson = {..._kBudgetJson, 'id': 'server-b'};
      final svc = _makeService(
        (_) => http.Response(jsonEncode(createdJson), 201),
      );

      final result = await svc.createBudget(_fakeBudget());
      expect(result.id, 'server-b');
    });

    test('strips id, user_id, and created_at from request body', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kBudgetJson), 201);
      });

      await svc.createBudget(_fakeBudget(id: 'strip-me'));
      final body = jsonDecode(captured.body) as Map;
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('user_id'), isFalse);
      expect(body.containsKey('created_at'), isFalse);
    });

    test('throws on non-201 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Bad request'}), 400),
      );
      expect(() => svc.createBudget(_fakeBudget()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('BudgetService.updateBudget', () {
    test('returns updated budget on 200', () async {
      final updatedJson = {..._kBudgetJson, 'limit_amount': 750.0};
      final svc = _makeService(
        (_) => http.Response(jsonEncode(updatedJson), 200),
      );

      final result = await svc.updateBudget(_fakeBudget());
      expect(result.limitAmount, 750.0);
    });

    test('sends PUT to /budgets/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kBudgetJson), 200);
      });

      await svc.updateBudget(_fakeBudget(id: 'b-42'));
      expect(captured.method, 'PUT');
      expect(captured.url.path, endsWith('/budgets/b-42'));
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.updateBudget(_fakeBudget()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteBudget
  // ────────────────────────────────────────────────────────────────────────────

  group('BudgetService.deleteBudget', () {
    test('completes without error on 204', () async {
      final svc = _makeService((_) => http.Response('', 204));
      await expectLater(svc.deleteBudget('b1'), completes);
    });

    test('sends DELETE to /budgets/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response('', 204);
      });

      await svc.deleteBudget('b-77');
      expect(captured.method, 'DELETE');
      expect(captured.url.path, endsWith('/budgets/b-77'));
    });

    test('throws on non-204 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.deleteBudget('missing'), throwsA(isA<Exception>()));
    });
  });
}
