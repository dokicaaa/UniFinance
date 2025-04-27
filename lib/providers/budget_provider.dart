import 'package:flutter/material.dart';
import 'package:banking4students/services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  List<dynamic> _budgetSummary = [];
  List<dynamic> _pendingBudgets = [];
  bool _isLoading = false;

  List<dynamic> get budgetSummary => _budgetSummary;
  List<dynamic> get pendingBudgets => _pendingBudgets;
  bool get isLoading => _isLoading;

  Future<void> loadBudgetSummary({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (_budgetSummary.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    final result = await BudgetService.fetchBudgetSummary();

    if (result != null) {
      _budgetSummary = result["budget_updates"] ?? [];
      _pendingBudgets = result["categories_needing_budget"] ?? [];
    } else {
      _budgetSummary = [];
      _pendingBudgets = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBudget(String category, double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await BudgetService.createBudget(category, amount);

      // ✅ Remove the pending budget from the list
      _pendingBudgets.removeWhere((b) => b["category"] == category);

      // ✅ Re-fetch budget summary to update UI
      await loadBudgetSummary(forceRefresh: true);
    } catch (e) {
      print("Error creating budget: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void declineBudget(String category) {
    _pendingBudgets.removeWhere((budget) => budget["category"] == category);
    notifyListeners();
  }
}
