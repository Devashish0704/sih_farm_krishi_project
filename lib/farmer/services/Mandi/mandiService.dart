import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/Crop.dart';

class MandiService {
  static const String baseUrl = 'https://sih-crop-details-api.vercel.app/api';

  Future<List<Crop>> fetchCropsByState(String stateName,
      {String? language}) async {
    try {
      // Create form data
      final Map<String, String> formData = {
        'language': language ?? 'en',
        'stateName': stateName,
        'fromDate': "2024-03-27",
        'toDate': "2024-03-27",
      };

      final response = await http.post(
        Uri.parse('$baseUrl/commodities/state'), // Changed to /trade endpoint
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        print("response yo $data");

        // Ensure that 'data' is a List
        if (data['data'] is List) {
          final List<dynamic> tradeList = data['data'];
          return tradeList.map((item) => Crop.fromJson(item)).toList();
        } else {
          throw Exception('Expected a list but got: ${data['data']}');
        }
      } else {
        throw Exception('Failed to load crops: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crops: $e');
    }
  }

  Future<List<Crop>> fetchCropsByAPMC(String stateName, String apmcName,
      {String? language}) async {
    try {
      final Map<String, String> formData = {
        'language': language ?? 'en',
        'stateName': stateName,
        'apmcName': apmcName,
        'fromDate': _getTodayDate(),
        'toDate': _getTodayDate(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/trade'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> tradeList = data['records'] ?? [];
        return tradeList.map((item) => Crop.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load crops: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crops: $e');
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
