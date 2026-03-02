import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Fetches ML-driven spending recommendations from the API.
class RecommendationService {
  final ApiClient _api;

  RecommendationService(this._api);

  Future<List<Recommendation>> fetchRecommendations() async {
    final res = await _api.get('/recommendations');
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch recommendations');
    }

    final list = jsonDecode(res.body) as List;
    return list
        .map((j) => Recommendation.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
