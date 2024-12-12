import 'package:e_commerce_app_flutter/data/urls.dart';

import 'network/network_api_services.dart';

class ApiRepo {
  final _apiService = NetworkApiService();

  Future<dynamic> navigationAi(var data) async {
    print(data);
    dynamic response = _apiService.postApi(data, AppUrl.navigationAI);
    return response;
  }

  Future<dynamic> rainfallAi(var data) async {
    print(data);
    dynamic response = _apiService.postApi(data, AppUrl.rainfall_api);
    return response;
  }

  Future<dynamic> navigationAiGet() async {
    //   print(data);
    dynamic response = _apiService.getApi(AppUrl.navigationAI);
    return response;
  }
}
