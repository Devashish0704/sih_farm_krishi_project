import 'dart:async';

import 'package:e_commerce_app_flutter/services/dp-ratio/sort_for_price.dart';

class CropDetailsStream {
  // StreamController for crop details
  final StreamController<Map<String, dynamic>> _cropDetailsController =
      StreamController<Map<String, dynamic>>();

  // Expose the stream for listening
  Stream<Map<String, dynamic>> get cropDetailsStream =>
      _cropDetailsController.stream;

  // Function to fetch crop details and add them to the stream
  Future<void> fetchCropDetails(String category) async {
    try {
      Map<String, Map<String, String>> productDetails =
          await getProductIdsAndPricesForCategory(category.toLowerCase());

      print(productDetails);

      // Add data to the stream
      _cropDetailsController.add(productDetails);
    } catch (e) {
      // Add error to the stream
      _cropDetailsController.addError(e);
    }
  }

  // Dispose the StreamController
  void dispose() {
    _cropDetailsController.close();
  }
}
