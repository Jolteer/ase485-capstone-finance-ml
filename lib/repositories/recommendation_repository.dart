/// Recommendation repository - thin layer between [RecommendationProvider]
/// and the HTTP service.
library;

import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/recommendation_service.dart';

class RecommendationRepository {
  final RecommendationService _service;

  RecommendationRepository({
    required ApiClient apiClient,
    RecommendationService? service,
  }) : _service = service ?? RecommendationService(apiClient);

  Future<List<Recommendation>> fetch() => _service.fetchRecommendations();

  /// Re-runs the ML rule engine on the server and returns the new tips.
  Future<List<Recommendation>> regenerate() =>
      _service.generateRecommendations();
}
