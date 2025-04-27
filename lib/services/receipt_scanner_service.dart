import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ReceiptScannerService {
  static const String baseUrl = ""; // Replace with your actual server IP

  static Future<List<Map<String, dynamic>>?> scanReceipt(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/scan_check'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("HTTP Response Code: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Try decoding the response
        final decodedJson = jsonDecode(response.body);
        // Check that the key "items" exists and is a list.
        if (decodedJson is Map &&
            decodedJson.containsKey("items") &&
            decodedJson["items"] is List) {
          return List<Map<String, dynamic>>.from(decodedJson["items"]);
        } else {
          print("Unexpected JSON structure: ${decodedJson}");
          return [];
        }
      } else {
        print("Failed to scan receipt: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error scanning receipt: $e");
      return null;
    }
  }
}
