import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';

/// State-management class for the user’s per-category budgets.
///
/// Exposes the budget list plus loading/error flags so the UI can
/// react to network activity.
class BudgetProvider extends ChangeNotifier {
  /// Service used to perform budget API calls.
  final BudgetService _service;

  /// The user’s current set of budgets.
  List<Budget> _budgets = [];

  /// True while fetching or generating budgets.
  bool _isLoading = false;

  /// Human-readable error from the most recent failed call.
  String? _error;

  BudgetProvider(this._service);

  // --------------- public getters ---------------

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --------------- actions ---------------

  /// Fetch existing budgets from the API and replace the local list.
  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _service.getBudgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ask the ML backend to generate personalised budgets from the
  /// user’s spending history. Replaces the entire local budget list
  /// with the newly generated budgets.
  Future<void> generateBudget() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _service.generateBudget();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
