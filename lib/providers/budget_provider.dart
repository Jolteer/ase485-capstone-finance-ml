import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';

/// Manages the list of per-category budgets.
class BudgetProvider extends ChangeNotifier {
  final BudgetService _service;

  BudgetProvider(this._service);

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Look up the budget for a specific category (if any).
  Budget? budgetForCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  /// Fetch all budgets from the service.
  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      _budgets = await _service.getBudgets();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new budget and append it to the list.
  Future<void> addBudget({
    required String category,
    required double limitAmount,
    required String period,
  }) async {
    _setLoading(true);
    try {
      final b = await _service.addBudget(
        category: category,
        limitAmount: limitAmount,
        period: period,
      );
      _budgets = [..._budgets, b];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
