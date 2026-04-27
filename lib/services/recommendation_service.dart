/// Fetches ML-driven spending recommendations from the API (read-only). Used by recommendations feature.
///
/// GET /recommendations; throws on non-success.
library;

import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Fetches ML-driven spending recommendations from the API.
class RecommendationService {
  final ApiClient _api;

  RecommendationService(this._api);

  /// GET /recommendations; returns list of [Recommendation].
  Future<List<Recommendation>> fetchRecommendations() async {
    final res = await _api.get('/recommendations');
    return ApiClient.decodeJsonList(res, Recommendation.fromJson);
  }

  /// POST /ml/recommendations/generate; regenerates recommendations via ML.
  Future<List<Recommendation>> generateRecommendations() async {
    final res = await _api.post('/ml/recommendations/generate');
    return ApiClient.decodeJsonList(res, Recommendation.fromJson);
  }
}
