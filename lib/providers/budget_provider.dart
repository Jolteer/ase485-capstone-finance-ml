import 'package:flutter/foundation.dart';
import '../models/budget.dart';

/// Manages budget state and ML-generated budget data.
class BudgetProvider extends ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  // TODO: Load generated budgets
  // TODO: Refresh budget from ML model
}
