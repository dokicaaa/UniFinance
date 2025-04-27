import 'dart:convert';
import 'package:http/http.dart' as http;

class WeeklyPlanService {
  static const String baseUrl = ""; // Update this

  static Future<Map<String, dynamic>?> fetchWeeklyPlan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/weekly_plan'));

      print("HTTP Response Code: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        print("Decoded JSON: $decodedJson");
        return decodedJson;
      } else {
        print("Failed to fetch weekly plan: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error fetching weekly plan: $e");
      return {};
    }
  }
}
