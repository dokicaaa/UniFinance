import 'dart:convert';
import 'package:http/http.dart' as http;

class BudgetService {
  static const String _baseUrl = "";

  /// Fetches the budget summary and pending budgets.
  static Future<Map<String, dynamic>?> fetchBudgetSummary() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/budget_summary"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching budget summary: $e");
    }
    return null;
  }

  /// Sends a request to create a new budget if the user approves it.
  static Future<bool> createBudget(String category, double amount) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/create_budget"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category": category, "suggested_budget": amount}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error creating budget: $e");
    }
    return false;
  }
}
