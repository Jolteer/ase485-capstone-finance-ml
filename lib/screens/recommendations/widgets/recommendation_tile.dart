/// Card row for one [Recommendation]: category icon, title, description,
/// and potential savings amount.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class RecommendationTile extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationTile({super.key, required this.recommendation});

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
