import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages budget list state and exposes helpers for CRUD operations.
class BudgetProvider extends ChangeNotifier {
  late final BudgetService _service;

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  BudgetProvider({required ApiClient apiClient}) {
    _service = BudgetService(apiClient);
  }

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Clears any previous error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _service.fetchBudgets();
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    _error = null;
    try {
      final created = await _service.createBudget(budget);
      _budgets.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    _error = null;
    try {
      final updated = await _service.updateBudget(budget);
      final idx = _budgets.indexWhere((b) => b.id == budget.id);
      if (idx != -1) _budgets[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    _error = null;
    try {
      await _service.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
