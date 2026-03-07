/// Recommendations list: AI insights banner and tiles showing tip + potential savings.
///
/// Reads [RecommendationProvider] for live data. [LoadingOverlay] covers the
/// screen while fetching; errors surface as a [SnackBar]. Shows an empty-state
/// message when no recommendations are available.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/providers/recommendation_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

/// Screen listing savings recommendations with an "AI-Powered Insights" banner
/// and [_RecommendationTile]s sourced from [RecommendationProvider].
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  RecommendationProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<RecommendationProvider>();
    if (_provider != provider) {
      _provider?.removeListener(_onProviderChanged);
      _provider = provider..addListener(_onProviderChanged);
      if (_provider!.recommendations.isEmpty && !_provider!.isLoading) {
        _provider!.fetchRecommendations();
      }
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    final error = _provider?.error;
    if (error != null && mounted) {
      _provider!.clearError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
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
            ? const _EmptyState()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const _InsightsBanner(),
                  const SizedBox(height: AppSpacing.md),
                  ...recommendations.map(
                    (r) => _RecommendationTile(recommendation: r),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState
// ---------------------------------------------------------------------------

/// Shown when there are no recommendations and the screen is not loading.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: theme.colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No recommendations yet.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add some transactions and we\'ll generate\npersonalised savings tips for you.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _InsightsBanner  (unchanged)
// ---------------------------------------------------------------------------

/// Primary-container card with "AI-Powered Insights" icon and subtitle.
class _InsightsBanner extends StatelessWidget {
  const _InsightsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-Powered Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Based on your spending patterns, here are ways to save.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RecommendationTile  (unchanged)
// ---------------------------------------------------------------------------

/// Card row for one [Recommendation]: category icon, title, description,
/// and potential savings amount.
class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final color = Categories.color(recommendation.category);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(Categories.icon(recommendation.category), color: color),
        ),
        title: Text(
          recommendation.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(recommendation.description),
        trailing: Text(
          'Save ${Formatters.currency(recommendation.potentialSavings)}',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
