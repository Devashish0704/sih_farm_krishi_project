import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class FavouriteProductsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final favProductsFuture = UserDatabaseHelper().usersFavouriteProductsList;

    favProductsFuture.then((favProducts) {
      if (favProducts.isNotEmpty) {
        //  print("favProducts: $favProducts");
        addData(favProducts.cast<String>());
      } else {
        print("No favourite products found");
        addData([]); // Add an empty list if no favorite products are found
      }
    }).catchError((e) {
      print("Error loading favourite products: $e");
      addError(e);
    });
  }
}
