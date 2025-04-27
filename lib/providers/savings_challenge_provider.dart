import 'package:flutter/material.dart';
import 'package:banking4students/services/savings_challenge_service.dart';

class SavingsChallengeProvider extends ChangeNotifier {
  Map<String, dynamic>? _savingsChallenge;
  bool _isLoading = false;

  Map<String, dynamic>? get savingsChallenge => _savingsChallenge;
  bool get isLoading => _isLoading;

  Future<void> loadSavingsChallenge({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (_savingsChallenge != null &&
        _savingsChallenge!.isNotEmpty &&
        !forceRefresh) {
      return; // Prevents unnecessary re-fetching
    }

    _isLoading = true;
    notifyListeners();

    final result = await SavingsChallengeService.fetchSavingsChallenge();
    print("Savings Challenge Fetched: $result");

    if (result != null && result.isNotEmpty) {
      _savingsChallenge = result;
    } else {
      _savingsChallenge = null; // Keep it null if fetching fails
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetSavingsChallenge() {
    _savingsChallenge = null; // Ensure a full refresh on next load
    notifyListeners();
  }
}
