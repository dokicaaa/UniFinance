import 'package:flutter/material.dart';
import 'package:banking4students/services/weekly_plan_service.dart';

class WeeklyPlanProvider extends ChangeNotifier {
  Map<String, dynamic>? _weeklyPlan;
  bool _isLoading = false;

  Map<String, dynamic>? get weeklyPlan => _weeklyPlan;
  bool get isLoading => _isLoading;

  Future<void> loadWeeklyPlan({bool forceRefresh = false}) async {
    if (_isLoading) return; // Prevent multiple fetches at once

    if (_weeklyPlan != null && _weeklyPlan!.isNotEmpty && !forceRefresh) {
      return; // Prevent unnecessary re-fetching if data exists
    }

    _isLoading = true;
    notifyListeners();

    // Wait for at least a short duration before setting loading false (prevents flickering)
    await Future.delayed(Duration(milliseconds: 10000));

    final result = await WeeklyPlanService.fetchWeeklyPlan();
    print("Weekly Plan Fetched: $result");

    if (result != null && result.isNotEmpty) {
      _weeklyPlan = result;
    } else {
      _weeklyPlan = null; // Keep it null if fetching fails
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetWeeklyPlan() {
    _weeklyPlan = null; // Ensure a full refresh on next load
    notifyListeners();
  }
}
