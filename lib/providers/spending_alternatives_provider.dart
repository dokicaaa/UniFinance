import 'package:flutter/material.dart';
import 'package:banking4students/services/spending_alternatives_service.dart';

class SpendingAlternativesProvider extends ChangeNotifier {
  Map<String, dynamic>? _spendingAlternatives;
  bool _isLoading = false;

  Map<String, dynamic>? get spendingAlternatives => _spendingAlternatives;
  bool get isLoading => _isLoading;

  Future<void> loadSpendingAlternatives({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (_spendingAlternatives != null &&
        _spendingAlternatives!.isNotEmpty &&
        !forceRefresh) {
      return; // Prevents unnecessary re-fetching
    }

    _isLoading = true;
    notifyListeners();

    final result =
        await SpendingAlternativesService.fetchSpendingAlternatives();
    print("Spending Alternatives Fetched: $result");

    if (result != null && result.isNotEmpty) {
      _spendingAlternatives = result;
    } else {
      _spendingAlternatives = null; // Keep it null if fetching fails
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetSpendingAlternatives() {
    _spendingAlternatives = null; // Ensure a full refresh on next load
    notifyListeners();
  }
}
