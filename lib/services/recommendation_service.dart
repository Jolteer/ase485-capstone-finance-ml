import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/mock_api_client.dart';

/// Fetches ML-generated savings recommendations from the API or mock data.
class RecommendationService {
  final ApiClient _api;

  RecommendationService(this._api);

  /// Get all recommendations for the current user.
  Future<List<Recommendation>> getRecommendations() async {
    if (useMockApi) return MockApiClient.getRecommendations();
    final json = await _api.get('/recommendations');
    final list = json['data'] as List;
    return list
        .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
