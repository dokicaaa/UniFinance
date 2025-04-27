import 'dart:convert';
import 'package:http/http.dart' as http;

class SpendingAlternativesService {
  static const String baseUrl = ""; // Replace this

  static Future<Map<String, dynamic>?> fetchSpendingAlternatives() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spending_alternatives'),
      );

      print("HTTP Response Code: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        print("Decoded JSON: $decodedJson");
        return decodedJson;
      } else {
        print("Failed to fetch spending alternatives: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error fetching spending alternatives: $e");
      return {};
    }
  }
}
