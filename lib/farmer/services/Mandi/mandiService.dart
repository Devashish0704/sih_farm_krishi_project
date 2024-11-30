import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

        // Ensure that 'data' is a List
        if (data['data'] is List) {
          final List<dynamic> tradeList = data['data'];
          print("all is well fetchCropsByState");
          return tradeList.map((item) => Crop.fromJson(item)).toList();
        } else if (data['data'] is Map) {
          // Handle the case where 'data' is a Map
          throw Exception('Expected a list but got a map: ${data['data']}');
        } else {
          throw Exception('Unexpected data type: ${data['data']}');
        }
      } else {
        throw Exception('Failed to load crops: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crops: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStates() async {
    final response = await http.get(Uri.parse('$baseUrl/states'));

    if (response.statusCode == 200) {
      try {
        // Decode the response body
        final Map<String, dynamic> decodedData = json.decode(response.body);

        // Extract the "data" key which contains the list of states
        final List<dynamic> states = decodedData['data'];

        // Map the list to extract both "state_name" and "state_id"
        return states.map((state) {
          return {
            'state_name': state['state_name'], // State name as string
            'state_id': state[
                'state_id'], // State ID as dynamic (could be String or int)
          };
        }).toList();
      } catch (e) {
        // Handle decoding or type errors
        print("Error decoding response: $e");
        throw Exception('Failed to parse the response.');
      }
    } else {
      // Handle non-200 status codes
      throw Exception('Failed to load states: ${response.statusCode}');
    }
  }

  // Fetch APMCs by state
  Future<List<Map<String, dynamic>>> fetchAPMCs(String stateId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apmc'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'state_id': stateId},
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      try {
        // Decode the response body
        final Map<String, dynamic> decodedData = json.decode(response.body);

        // Extract the "data" key which contains the list of APMCs
        final List<dynamic> apmcs = decodedData['data'];

        // Map the list to extract both "apmc_name" and "apmc_id"
        return apmcs.map((apmc) {
          return {
            'apmc_name': apmc['apmc_name'], // APMC name as string
            'apmc_id':
                apmc['apmc_id'], // APMC ID as dynamic (could be String or int)
          };
        }).toList();
      } catch (e) {
        // Handle decoding or type errors
        print("Error decoding response: $e");
        throw Exception('Failed to parse the response.');
      }
    } else {
      // Handle non-200 status codes
      throw Exception('Failed to load APMCs: ${response.statusCode}');
    }
  }

  // Fetch commodities by APMC
  Future<List<Crop>> fetchCropsByAPMC(String stateName, String apmcName) async {
    try {
      print("sname , apname ${stateName + " " + apmcName}");
      final response = await http.post(
        Uri.parse('$baseUrl/commodities/apmc'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'stateName': stateName,
          'apmcName': apmcName,
          "fromDate": "2022-11-29",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("response yo $data");

        // Ensure that 'data' is a List
        if (data['data'] is List) {
          final List<dynamic> cropList = data['data'];
          return cropList.map((item) => Crop.fromJson(item)).toList();
        } else if (data['data'] is Map) {
          // Handle the case where 'data' is a Map
          throw Exception('Expected a list but got a map: ${data['data']}');
        } else {
          throw Exception('Unexpected data type: ${data['data']}');
        }
      } else {
        throw Exception('Failed to load crops by APMC: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crops by APMC: $e');
    }
  }

  Future<String> getStateFromLocation(Position position) async {
    try {
      // print("position yo service $position");
      // Use Geocoding to get placemarks based on latitude and longitude
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Ensure we have at least one placemark and a non-null administrativeArea
      if (placemarks.isNotEmpty) {
        String? state = placemarks.first.administrativeArea;
        if (state != null && state.isNotEmpty) {
          return state;
        } else {
          throw Exception('State could not be determined from placemark.');
        }
      } else {
        throw Exception('No placemarks found for the provided location.');
      }
    } catch (e) {
      // Handle errors gracefully
      throw Exception('Error fetching state from location: $e');
    }
  }
}
