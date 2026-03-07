/// Tests for GoalService: fetch, create, update, delete.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _kGoalJson = <String, dynamic>{
  'id': 'g1',
  'user_id': 'u1',
  'target_amount': 5000.0,
  'target_date': '2027-01-01T00:00:00.000Z',
  'description': 'Vacation fund',
  'progress': 1000.0,
  'category': 'vacation',
};

Goal _fakeGoal({String id = 'g1'}) => Goal(
  id: id,
  userId: 'u1',
  targetAmount: 5000.0,
  targetDate: DateTime.utc(2027, 1, 1),
  description: 'Vacation fund',
  progress: 1000.0,
  category: GoalCategory.vacation,
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

  GoalService _makeService(http.Response Function(http.Request) handler) {
    final api = ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
    return GoalService(api);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // fetchGoals
  // ────────────────────────────────────────────────────────────────────────────

  group('GoalService.fetchGoals', () {
    test('returns parsed list on 200', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode([_kGoalJson]), 200),
      );

      final result = await svc.fetchGoals();
      expect(result, hasLength(1));
      expect(result.first.id, 'g1');
      expect(result.first.targetAmount, 5000.0);
      expect(result.first.category, GoalCategory.vacation);
    });

    test('returns empty list when response array is empty', () async {
      final svc = _makeService((_) => http.Response('[]', 200));
      expect(await svc.fetchGoals(), isEmpty);
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );
      expect(() => svc.fetchGoals(), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // createGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('GoalService.createGoal', () {
    test('returns created goal with server id on 201', () async {
      final createdJson = {..._kGoalJson, 'id': 'server-g'};
      final svc = _makeService(
        (_) => http.Response(jsonEncode(createdJson), 201),
      );

      final result = await svc.createGoal(_fakeGoal());
      expect(result.id, 'server-g');
    });

    test('strips id and user_id from request body', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kGoalJson), 201);
      });

      await svc.createGoal(_fakeGoal(id: 'strip-me'));
      final body = jsonDecode(captured.body) as Map;
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('user_id'), isFalse);
    });

    test('throws on non-201 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Bad request'}), 400),
      );
      expect(() => svc.createGoal(_fakeGoal()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // updateGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('GoalService.updateGoal', () {
    test('returns updated goal on 200', () async {
      final updatedJson = {..._kGoalJson, 'progress': 2500.0};
      final svc = _makeService(
        (_) => http.Response(jsonEncode(updatedJson), 200),
      );

      final result = await svc.updateGoal(_fakeGoal());
      expect(result.progress, 2500.0);
    });

    test('sends PUT to /goals/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response(jsonEncode(_kGoalJson), 200);
      });

      await svc.updateGoal(_fakeGoal(id: 'g-42'));
      expect(captured.method, 'PUT');
      expect(captured.url.path, endsWith('/goals/g-42'));
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.updateGoal(_fakeGoal()), throwsA(isA<Exception>()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // deleteGoal
  // ────────────────────────────────────────────────────────────────────────────

  group('GoalService.deleteGoal', () {
    test('completes without error on 204', () async {
      final svc = _makeService((_) => http.Response('', 204));
      await expectLater(svc.deleteGoal('g1'), completes);
    });

    test('sends DELETE to /goals/:id', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response('', 204);
      });

      await svc.deleteGoal('g-77');
      expect(captured.method, 'DELETE');
      expect(captured.url.path, endsWith('/goals/g-77'));
    });

    test('throws on non-204 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Not found'}), 404),
      );
      expect(() => svc.deleteGoal('missing'), throwsA(isA<Exception>()));
    });
  });
}
