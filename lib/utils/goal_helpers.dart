/// UI-layer helpers for [GoalCategory].
///
/// Import this file in widget/screen code that needs an icon for a goal
/// category. Keeping icon data here (rather than on the domain enum) ensures
/// lib/models/goal.dart stays free of Flutter dependencies.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';

export 'package:ase485_capstone_finance_ml/models/goal.dart' show GoalCategory;

/// UI-layer extension on [GoalCategory].
///
/// Provides [icon] without coupling the domain enum to Flutter.
/// Widgets must import this file (lib/utils/goal_helpers.dart) to activate it.
extension GoalCategoryUi on GoalCategory {
  /// Display icon for this goal category.
  IconData get icon {
    switch (this) {
      case GoalCategory.vacation:
        return Icons.beach_access;
      case GoalCategory.home:
        return Icons.home;
      case GoalCategory.emergency:
        return Icons.warning_amber;
      case GoalCategory.car:
        return Icons.directions_car;
      case GoalCategory.other:
        return Icons.flag;
    }
  }
}
