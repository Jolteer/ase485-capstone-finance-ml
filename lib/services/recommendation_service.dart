import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service that retrieves ML-generated savings recommendations.
///
/// The backend analyses spending patterns and returns personalised tips
/// (at least [AppConstants.minRecommendations] per analysis).
class RecommendationService {
  final ApiClient _api;

  RecommendationService(this._api);

  /// Fetch the list of savings recommendations for the authenticated user.
  /// Each [Recommendation] includes a title, description, related category,
  /// and an estimated dollar amount the user could save.
  Future<List<Recommendation>> getRecommendations() async {
    final data = await _api.get('/recommendations');
    final items = data['items'] as List;
    return items
        .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
