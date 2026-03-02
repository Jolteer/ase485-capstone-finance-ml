import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service layer for ML-generated spending recommendations.
/// 
/// Fetches personalized spending optimization recommendations generated
/// by machine learning algorithms on the backend.
class RecommendationService {
  /// The API client used for making HTTP requests.
  final ApiClient _api;

  /// Creates a [RecommendationService] instance with the given [ApiClient].
  RecommendationService(this._api);

  /// Fetches personalized recommendations for the current user.
  /// 
  /// Retrieves ML-generated suggestions based on the user's spending patterns,
  /// each with potential savings estimates.
  /// Returns a list of [Recommendation] objects.
  /// Throws an exception if the fetch fails.
  // TODO: Future<List<Recommendation>> fetchRecommendations()
}
