import 'dart:convert';
import 'package:http/http.dart' as http;

class MonthlyReportService {
  static const String baseUrl = "";

  static Future<Map<String, dynamic>?> fetchMonthlyReport() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/monthly_report'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error fetching monthly report: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching monthly report: $e");
      return null;
    }
  }
}
