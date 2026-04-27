/// Recommendations list: AI insights banner and tiles showing tip + potential savings.
///
/// Reads [RecommendationProvider] for live data. [LoadingOverlay] covers the
/// screen while fetching; errors surface as a [SnackBar]. Shows an empty-state
/// message when no recommendations are available.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/recommendation_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/recommendations/widgets/insights_banner.dart';
import 'package:ase485_capstone_finance_ml/screens/recommendations/widgets/recommendation_tile.dart';
import 'package:ase485_capstone_finance_ml/screens/recommendations/widgets/recommendations_empty_state.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Screen listing savings recommendations with an "AI-Powered Insights" banner
/// and [RecommendationTile]s sourced from [RecommendationProvider].
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with ProviderErrorMixin {
  bool _didTriggerInitialFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<RecommendationProvider>();
    listenForErrors<RecommendationProvider>(
      provider,
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    // Auto-fetch once per screen instance. Gating on a one-shot flag (rather
    // than `recommendations.isEmpty`) is required because build() calls
    // context.watch — every provider notify re-runs didChangeDependencies, so
    // an empty-list check after a failed or empty fetch would loop forever.
    if (!_didTriggerInitialFetch) {
      _didTriggerInitialFetch = true;
      if (provider.recommendations.isEmpty && !provider.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) provider.fetchRecommendations();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final recommendations = provider.recommendations;

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Recommendations')),
        body: recommendations.isEmpty && !provider.isLoading
            ? const RecommendationsEmptyState()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const InsightsBanner(),
                  const SizedBox(height: AppSpacing.md),
                  ...recommendations.map(
                    (r) => RecommendationTile(recommendation: r),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              context.read<RecommendationProvider>().generateRecommendations(),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Refresh Tips'),
        ),
      ),
    );
  }
}
