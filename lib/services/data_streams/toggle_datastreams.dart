import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';

class BestSearchProductsStream extends DataStream<List<String>> {
  final String category;

  BestSearchProductsStream({required this.category});

  @override
  void reload() async {
    try {
      final bestSearchProducts = await ProductDatabaseHelper()
          .getProductsByCategoryAndRating(category);
      addData(bestSearchProducts.map((product) => product.id).toList());
    } catch (e) {
      addError(e);
    }
  }
}

class NearbyProductsStream extends DataStream<List<String>> {
  final String category;

  NearbyProductsStream({required this.category});

  @override
  void reload() async {
    try {
      final nearbyProducts =
          await ProductDatabaseHelper().getNearbyProducts(category);
      addData(nearbyProducts.map((product) => product.id).toList());
    } catch (e) {
      addError(e);
    }
  }
}
