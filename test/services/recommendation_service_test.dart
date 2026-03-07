/// Tests for RecommendationService: fetch list.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/recommendation_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _kRecJson = <String, dynamic>{
  'id': 'r1',
  'category': 'Food',
  'title': 'Cook at home',
  'description': 'Save money by cooking instead of dining out.',
  'potential_savings': 150.0,
};

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

  RecommendationService _makeService(
    http.Response Function(http.Request) handler,
  ) {
    final api = ApiClient(
      client: MockClient((req) async => handler(req)),
      storage: storage,
    );
    return RecommendationService(api);
  }

  group('RecommendationService.fetchRecommendations', () {
    test('returns parsed list on 200', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode([_kRecJson]), 200),
      );

      final result = await svc.fetchRecommendations();
      expect(result, hasLength(1));
      expect(result.first.id, 'r1');
      expect(result.first.category, 'Food');
      expect(result.first.title, 'Cook at home');
      expect(result.first.potentialSavings, 150.0);
    });

    test('returns empty list when response array is empty', () async {
      final svc = _makeService((_) => http.Response('[]', 200));
      expect(await svc.fetchRecommendations(), isEmpty);
    });

    test('parses multiple recommendations', () async {
      final second = {
        ..._kRecJson,
        'id': 'r2',
        'title': 'Cancel subscriptions',
      };
      final svc = _makeService(
        (_) => http.Response(jsonEncode([_kRecJson, second]), 200),
      );

      final result = await svc.fetchRecommendations();
      expect(result, hasLength(2));
      expect(result[1].title, 'Cancel subscriptions');
    });

    test('sends GET to /recommendations', () async {
      late http.Request captured;
      final svc = _makeService((req) {
        captured = req;
        return http.Response('[]', 200);
      });

      await svc.fetchRecommendations();
      expect(captured.method, 'GET');
      expect(captured.url.path, endsWith('/recommendations'));
    });

    test('throws on non-200 status', () async {
      final svc = _makeService(
        (_) => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );
      expect(() => svc.fetchRecommendations(), throwsA(isA<Exception>()));
    });
  });
}
