import 'dart:convert';
import 'dart:io';
import 'package:e_commerce_app_flutter/data/api_exception.dart';
import 'base_api_services.dart';
import 'package:http/http.dart' as http;

class NetworkApiService extends BaseApiServices {
  @override
  Future<dynamic> postApi(var data, String url) async {
    String requestBodyJson = jsonEncode(data);
    print(requestBodyJson);
    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'APPLICATION/json',
          },
          body: requestBodyJson);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Unknown error';
        throw ApiException(response.statusCode, errorMessage);
      }
    } on SocketException {
      throw NetworkException('No internet connection.');
    } catch (error) {
      rethrow; // Rethrow for unexpected errors
    }
  }

  @override
  Future getApi(String url) async {
    //  String token = await SaveSPValues().getStringValues(Keys().tokenKey);

    try {
      final response = await http.get(
        Uri.parse(url),
        // headers: {'Content-Type': 'APPLICATION/json', 'authorization': token},
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Unknown error';
        throw ApiException(response.statusCode, errorMessage);
      }
    } on SocketException {
      throw NetworkException('No internet connection.');
    } catch (error) {
      rethrow; // Rethrow for unexpected errors
    }
  }
}
