import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageService {
  // Base URL of your API endpoint
  final String baseUrl = 'https://localhost:4000';

  // Method to send a text message
  Future<bool> sendTextMessage(
      {required String phoneNumber, required String message}) async {
    try {
      // Construct the full API endpoint
      final uri = Uri.parse(
          'https://localhost:4000/send?number=$phoneNumber,message=$message');
      print(uri);
      // Prepare the request body
      // final body = jsonEncode({'number': phoneNumber, 'message': message});

      // Make the POST request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers like authorization if needed
          // 'Authorization': 'Bearer YOUR_TOKEN'
        },
        // body: body,
      );

      // Check the response
      if (response.statusCode == 200) {
        // Parse the response
        final responseBody = jsonDecode(response.body);
        print(responseBody);
        return responseBody['success'] ?? false;
      } else {
        // Handle error scenarios
        print('Failed to send message. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle any network or processing errors
      print('Error sending message: $e');
      return false;
    }
  }

  // Example usage method
  void exampleUsage() async {
    bool success = await sendTextMessage(
        phoneNumber: '1234567890', message: 'Hello, this is a test message!');

    if (success) {
      print('Message sent successfully');
    } else {
      print('Failed to send message');
    }
  }
}
