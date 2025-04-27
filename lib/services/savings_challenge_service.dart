import 'dart:convert';
import 'package:http/http.dart' as http;

class SavingsChallengeService {
  static const String baseUrl = ""; // Replace with actual server IP

  static Future<Map<String, dynamic>?> fetchSavingsChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/savings_challenge'));

      print("HTTP Response Code: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        print("Decoded JSON: $decodedJson");
        return decodedJson;
      } else {
        print("Failed to fetch savings challenge: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error fetching savings challenge: $e");
      return {};
    }
  }
}
