import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:banking4students/models/bill_item.dart';

class BillApiService {
  final String _apiKey = '';
  final String _openAiEndpoint =
      'https://your-backend-api.com/process_bill_image';

  /// This function sends the captured image file to your backend (or ChatGPT endpoint)
  /// and returns a list of bill items in JSON format.
  Future<List<BillItem>> processBillImage(File imageFile) async {
    // Create a multipart request
    final uri = Uri.parse(_openAiEndpoint);
    final request = http.MultipartRequest('POST', uri);

    // Add headers (your API key should be kept secret on the backend in production)
    request.headers['Authorization'] = 'Bearer $_apiKey';

    // Attach the image file (field name 'billImage' must match your backend expectation)
    request.files.add(
      await http.MultipartFile.fromPath('billImage', imageFile.path),
    );

    // Add other fields if required by your endpoint
    // For example, you might pass a JSON-encoded prompt in a field:
    request.fields['prompt'] = jsonEncode({
      "role": "system",
      "content":
          "Extract only the item name and price from the receipt image. Return JSON formatted like: [{\"itemName\": \"Coke\", \"price\": 3.65}, {\"itemName\": \"Pizza\", \"price\": 12.99}].",
    });
    request.fields['temperature'] = '0.2';
    request.fields['model'] = 'gpt-4o-mini';

    // Send the request
    final response = await request.send();

    // Process the response
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      final content = data['choices'][0]['message']['content'];
      // Assuming the content is a JSON array of objects
      return List<BillItem>.from(
        jsonDecode(content).map((json) => BillItem.fromJson(json)),
      );
    } else {
      throw Exception(
        'Failed to process bill: ${response.statusCode} ${await response.stream.bytesToString()}',
      );
    }
  }
}
