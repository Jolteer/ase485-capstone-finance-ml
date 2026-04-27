/// ML-driven recommendation list state: fetch all recommendations.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient]. Call
/// [fetchRecommendations] to load; [recommendations], [isLoading], and [error]
/// notify listeners.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/recommendation_service.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

/// Manages the list of [Recommendation]s and delegates to [RecommendationService] for API calls.
class RecommendationProvider extends ChangeNotifier with AsyncOperationMixin {
  final RecommendationService _service;

  List<Recommendation> _recommendations = [];

  /// Pass [service] in tests to inject a mock; production code omits it and
  /// requires [apiClient] to construct the default [RecommendationService].
  RecommendationProvider({
    required ApiClient apiClient,
    RecommendationService? service,
  }) : _service = service ?? RecommendationService(apiClient);

  /// Unmodifiable list of recommendations; load with [fetchRecommendations].
  List<Recommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  /// Fetches recommendations from the API and updates [recommendations].
  Future<void> fetchRecommendations() => runLoad(() async {
    _recommendations = await _service.fetchRecommendations();
  });

  /// Regenerates recommendations via ML analysis and updates [recommendations].
  Future<void> generateRecommendations() => runLoad(() async {
    _recommendations = await _service.generateRecommendations();
  });
}
