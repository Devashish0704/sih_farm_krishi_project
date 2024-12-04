import 'package:e_commerce_app_flutter/data/response/status.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse(this.status, this.data, this.message);
  ApiResponse.loading() : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETETD;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return 'ApiResponse{status: $status, data: $data, message: $message}';
  }
}
