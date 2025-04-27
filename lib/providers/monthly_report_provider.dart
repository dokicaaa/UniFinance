import 'package:flutter/material.dart';
import 'package:banking4students/services/monthly_report_service.dart';

class MonthlyReportProvider extends ChangeNotifier {
  Map<String, dynamic>? _monthlyReport;
  bool _isLoading = false;

  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  bool get isLoading => _isLoading;

  Future<void> loadMonthlyReport({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_monthlyReport != null && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    final result = await MonthlyReportService.fetchMonthlyReport();
    if (result != null) {
      _monthlyReport = result;
    } else {
      _monthlyReport = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetMonthlyReport() {
    _monthlyReport = null;
    notifyListeners();
  }
}
