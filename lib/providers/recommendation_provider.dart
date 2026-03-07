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
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages the list of [Recommendation]s and delegates to [RecommendationService] for API calls.
class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _service;

  List<Recommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  /// Pass [service] in tests to inject a mock; production code omits it and
  /// requires [apiClient] to construct the default [RecommendationService].
  RecommendationProvider({
    required ApiClient apiClient,
    RecommendationService? service,
  }) : _service = service ?? RecommendationService(apiClient);

  /// Unmodifiable list of recommendations; load with [fetchRecommendations].
  List<Recommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  /// True while [fetchRecommendations] is running.
  bool get isLoading => _isLoading;

  /// Last error from a fetch operation, or null. Clear with [clearError].
  String? get error => _error;

  /// Clears [error] and notifies listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetches recommendations from the API and updates [recommendations].
  Future<void> fetchRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _service.fetchRecommendations();
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
