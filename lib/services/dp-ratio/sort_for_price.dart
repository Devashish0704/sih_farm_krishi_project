import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchAndSortCropData(String cropName) async {
  try {
    print(1);
    // Reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('dp-ratio');

    print(2);
    // Fetch the document corresponding to the crop name
    DocumentSnapshot cropDoc = await collectionRef.doc(cropName).get();

    print(3);
    if (cropDoc.exists) {
      // Extract the 'states' map
      Map<String, dynamic> states = cropDoc['states'] as Map<String, dynamic>;

      print(4);
      // Transform the map into a list of state data with keys included
      List<Map<String, dynamic>> statesList = states.entries.map((entry) {
        return {
          'state': entry.key,
          'd_p': entry.value['d_p'],
          'price': entry.value['price'],
        };
      }).toList();
      print(5);

      // Sort the list by 'd_p' in descending order
      statesList
          .sort((a, b) => (b['d_p'] as double).compareTo(a['d_p'] as double));

      print(6);
      return statesList;
    } else {
      print('Document for crop $cropName does not exist.');
      return [];
    }
  } catch (e) {
    print('Error fetching crop data: $e');
    return [];
  }
}

double calculateTop10AveragePrice(List<Map<String, dynamic>> statesList) {
  if (statesList.isEmpty) {
    print('State list is empty. Cannot calculate average.');
    return 0.0;
  }

  // Take the top 10 states (or fewer if the list is smaller)
  List<Map<String, dynamic>> top10States = statesList.take(10).toList();

  // Calculate the average price
  double totalPrice =
      top10States.fold(0.0, (sum, state) => sum + (state['price'] as double));
  double averagePrice = totalPrice / top10States.length;

  return averagePrice;
}

Future<void> updateFixedPrice(String cropName, double fixedPrice) async {
  try {
    // Reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('crops-demand');

    // Update the 'fixed_price' field for the specific crop document
    await collectionRef.doc(cropName).update({'fixed_price': fixedPrice});
    print('Fixed price updated successfully for crop $cropName.');
  } catch (e) {
    print('Error updating fixed price: $e');
  }
}

Future<Map<String, Map<String, String>>> getProductKeysForStatesAndUpdatePrices(
    List<Map<String, dynamic>> sortedStatesList,
    String cropName,
    double fixedPrice) async {
  Map<String, Map<String, String>> stateProductDetails = {};
  print(0);
  try {
    // Reference to the Firestore collection
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    for (var stateData in sortedStatesList) {
      String stateName = stateData['state'];
      print(1);
      // Query the products collection for documents with matching state and cropName
      QuerySnapshot querySnapshot = await productsCollection
          .where('state', isEqualTo: stateName)
          .where('name', isEqualTo: cropName) // Using the provided cropName
          .get();

      print(2);
      if (querySnapshot.docs.isNotEmpty) {
        // Assume the first document is the match
        print(" proddocid ");
        print(2);
        DocumentSnapshot productDoc = querySnapshot.docs.first;

        print(" prod docid ${productDoc.data()}");
        // Update the price for this product ID
        print(" prod docid ${productDoc.id}");
        await updateFixedPricetoProducts(productDoc.id, fixedPrice);
        print(" prod doc id ${productDoc.id}");

        // Add details to the stateProductDetails map
        stateProductDetails[stateName] = {
          'productId': productDoc.id,
        };
      }
    }

    print('Price updated for all relevant products.');
  } catch (e) {
    print('Error fetching product details or updating prices: $e');
  }

  return stateProductDetails;
}

Future<void> updateFixedPricetoProducts(
    String productId, double fixedPrice) async {
  print(1);
  try {
    // Reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('products');

    print(3);
    // Update the 'price' field for the specific product document
    await collectionRef.doc(productId).update({'price': fixedPrice});
    print(4);
    print('Fixed price updated successfully for product ID $productId.');
  } catch (e) {
    print('Error updating fixed price: $e');
  }
}

// Future<Map<String, Map<String, String>>> getProductKeysForStates(
//     List<Map<String, dynamic>> sortedStatesList, String cropName) async {
//   Map<String, Map<String, String>> stateProductDetails = {};

//   try {
//     // Reference to the Firestore collection
//     CollectionReference productsCollection =
//         FirebaseFirestore.instance.collection('products');
//     print(1);

//     for (var stateData in sortedStatesList) {
//       String stateName = stateData['state'];

//       print(2);
//       // Query the products collection for documents with matching state and cropName
//       QuerySnapshot querySnapshot = await productsCollection
//           .where('state', isEqualTo: stateName)
//           .where('name', isEqualTo: cropName) // Using the provided cropName
//           .get();

//       print(3);
//       if (querySnapshot.docs.isNotEmpty) {
//         // Assume the first document is the match
//         DocumentSnapshot productDoc = querySnapshot.docs.first;
//         // Map<String, dynamic> productData =
//         //     productDoc.data() as Map<String, dynamic>;

//         print(4);
//         stateProductDetails[stateName] = {
//           'productId': productDoc.id,
//           // 'productName': productData['name'] ?? 'Unknown'
//         };
//       }
//     }
//     print(5);
//   } catch (e) {
//     print('Error fetching product details: $e');
//   }

//   return stateProductDetails;
// }

Future<Map<String, Map<String, String>>> getProductKeysForStatesusingCategory(
    List<Map<String, dynamic>> sortedStatesList, String categoryName) async {
  Map<String, Map<String, String>> stateProductDetails = {};

  try {
    // Reference to the Firestore collection
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');
    print(1);

    for (var stateData in sortedStatesList) {
      String stateName = stateData['state'];

      print(2);
      // Query the products collection for documents with matching state and category
      QuerySnapshot querySnapshot = await productsCollection
          .where('state', isEqualTo: stateName)
          .where('category',
              isEqualTo: categoryName) // Using the provided categoryName
          .get();

      print(3);
      if (querySnapshot.docs.isNotEmpty) {
        // Assume the first document is the match
        DocumentSnapshot productDoc = querySnapshot.docs.first;
        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;

        print(4);
        stateProductDetails[stateName] = {
          'productId': productDoc.id,
          'price': productData['price']?.toString() ?? 'Unknown'
        };
      }
    }
    print(5);
  } catch (e) {
    print('Error fetching product details: $e');
  }

  return stateProductDetails;
}

const Map<String, List<String>> cropCategories = {
  'fruits': ['banana', 'orange'],
  'vegetables': ['cauliflower', 'onion', 'potato', 'tomato'],
  'grains': ['rice', 'wheat'],
};

Future<Map<String, Map<String, String>>> getProductIdsAndPricesForCategory(
    String categoryName) async {
  Map<String, Map<String, String>> cropProductDetails = {};
  print(1);
  try {
    // Check if the category exists in the cropCategories map
    print(2);
    if (cropCategories.containsKey(categoryName)) {
      List<String> crops = cropCategories[categoryName]!;

      print(3);
      // Reference to the Firestore collection
      CollectionReference productsCollection =
          FirebaseFirestore.instance.collection('products');

      // Fetch details for each crop in the category
      print(4);
      for (String crop in crops) {
        // Query the products collection for a document with the matching crop name
        QuerySnapshot querySnapshot =
            await productsCollection.where('name', isEqualTo: crop).get();
        print(5);

        if (querySnapshot.docs.isNotEmpty) {
          // Assume the first document is the match
          DocumentSnapshot productDoc = querySnapshot.docs.first;
          Map<String, dynamic> productData =
              productDoc.data() as Map<String, dynamic>;

          print(6);
          // Store the productId and price in the map
          cropProductDetails[crop] = {
            'productId': productDoc.id,
            'price': productData['price']?.toString() ?? 'Unknown'
          };
        }
        print(7);
      }
    } else {
      print('Category not found: $categoryName');
    }
  } catch (e) {
    print('Error fetching product details: $e');
  }

  return cropProductDetails;
}
