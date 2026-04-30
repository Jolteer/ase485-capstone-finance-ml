/// ML-driven recommendation list state.
///
/// Backed by [RecommendationRepository].
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/repositories/recommendation_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

class RecommendationProvider extends ChangeNotifier with AsyncOperationMixin {
  final RecommendationRepository _repository;

  List<Recommendation> _recommendations = [];

  RecommendationProvider({
    required ApiClient apiClient,
    RecommendationRepository? repository,
  }) : _repository =
           repository ?? RecommendationRepository(apiClient: apiClient);

  /// Unmodifiable view of the loaded recommendations.
  List<Recommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  Future<void> fetchRecommendations() => runLoad(() async {
    _recommendations = await _repository.fetch();
  });

  /// Re-runs the ML rule engine on the server and refreshes the list.
  Future<void> generateRecommendations() => runLoad(() async {
    _recommendations = await _repository.regenerate();
  });
}
