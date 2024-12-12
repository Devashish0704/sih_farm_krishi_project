import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/farmer/models/User.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:geolocator/geolocator.dart';

class ProductDatabaseHelper {
  static const String PRODUCTS_COLLECTION_NAME = "products";
  static const String REVIEWS_COLLECTION_NAME = "reviews";

  ProductDatabaseHelper._privateConstructor();
  static final ProductDatabaseHelper _instance =
      ProductDatabaseHelper._privateConstructor();
  factory ProductDatabaseHelper() {
    return _instance;
  }

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firebaseFirestore;

  Position? userLocation; // Variable to store user location

  Future<List<String>> searchInProducts(String query,
      {String? category}) async {
    // print("query: $query category $category");
    Query<Map<String, dynamic>> queryRef;
    if (category == null) {
      queryRef = firestore.collection(PRODUCTS_COLLECTION_NAME);
      print("query ref: $queryRef");
    } else {
      // final categStr = EnumToString.convertToString(productType);
      queryRef = firestore
          .collection(PRODUCTS_COLLECTION_NAME)
          .where(Product.CATEGORY_KEY, isEqualTo: category);
    }

    Set<String> productsId = {};
    // final querySearchInTags = await queryRef
    //     .where(Product.SEARCH_TAGS_KEY, arrayContains: query)
    //     .get();
    // for (final doc in querySearchInTags.docs) {
    //   productsId.add(doc.id);
    // }
    final queryRefDocs = await queryRef.get();
    for (final doc in queryRefDocs.docs) {
      print("doc: ${doc.data()}");

      final product = Product.fromMap(doc.data(), id: doc.id);
      print(product);
      if (product.name!.toLowerCase().contains(query) ||
          // product.description!.toLowerCase().contains(query) ||
          // product.highlights.toString().toLowerCase().contains(query) ||
          product.variant.toString().toLowerCase().contains(query) ||
          product.seed_company!.toLowerCase().contains(query)) {
        productsId.add(product.id);
      }
    }
    print(productsId);
    return productsId.toList();
  }

  // Future<List<String>> searchInProducts(String query,
  //     {ProductType? productType}) async {
  //   Query<Map<String, dynamic>> queryRef;
  //   if (productType == null) {
  //     queryRef = firestore.collection(PRODUCTS_COLLECTION_NAME);
  //   } else {
  //     final productTypeStr = EnumToString.convertToString(productType);
  //     queryRef = firestore
  //         .collection(PRODUCTS_COLLECTION_NAME)
  //         .where(Product.PRODUCT_TYPE_KEY, isEqualTo: productTypeStr);
  //   }

  //   Set<String> productsId = {};
  //   // final querySearchInTags = await queryRef
  //   //     .where(Product.SEARCH_TAGS_KEY, arrayContains: query)
  //   //     .get();
  //   // for (final doc in querySearchInTags.docs) {
  //   //   productsId.add(doc.id);
  //   // }
  //   final queryRefDocs = await queryRef.get();
  //   for (final doc in queryRefDocs.docs) {
  //     final product = Product.fromMap(doc.data(), id: doc.id);
  //     if (product.name!.toLowerCase().contains(query) ||
  //         // product.description!.toLowerCase().contains(query) ||
  //         // product.highlights.toString().toLowerCase().contains(query) ||
  //         product.variant.toString().toLowerCase().contains(query) ||
  //         product.seed_company!.toLowerCase().contains(query)) {
  //       productsId.add(product.id);
  //     }
  //   }
  //   print(productsId);
  //   return productsId.toList();
  // }

  // Future<Map<String, dynamic>> fetchProductIdsAndPrice(
  //   String cropName,
  // ) async {
  //   // print("0");
  //   try {
  //     // Step 1: Fetch the crop document
  //     print("1");
  //     final cropDoc =
  //         await firestore.collection('crops-demand').doc(cropName).get();
  //     print("1a");
  //     // print(cropDoc.);

  //     if (!cropDoc.exists) {
  //       throw Exception("Crop document not found");
  //     }

  //     print("2");
  //     // Step 2: Extract and process state-level data
  //     Map<String, dynamic> cropData = cropDoc.data() ?? {};
  //     Map<String, dynamic> statesData =
  //         cropData['states'] ?? {}; // Explicitly access 'states'

  //     List<Map<String, dynamic>> statesList = [];
  //     for (var entry in statesData.entries) {
  //       final stateName =
  //           entry.key; // Should be 'himachalpradesh', 'tripura', etc.
  //       final stateData = entry.value;

  //       if (stateData is Map<String, dynamic>) {
  //         statesList.add({
  //           'state': stateName,
  //           'production': stateData['production'] ?? 0.0,
  //           'demand': stateData['demand'] ?? 0.0,
  //           'price': stateData['price'] ?? 0.0,
  //         });
  //       } else {
  //         print("Invalid data for state: $stateName");
  //       }
  //     }

  //     print("Processed states list: $statesList");

  //     print("3");

  //     // Sort states by production-demand difference (production - demand)
  //     statesList.sort((a, b) {
  //       double demandDiffA = a['production'] - a['demand'];
  //       double demandDiffB = b['production'] - b['demand'];
  //       return demandDiffB.compareTo(demandDiffA); // Descending order
  //     });
  //     // print("4");

  //     // Step 3: Calculate the average price of the top 10 states
  //     List<double> prices = statesList
  //         .map((state) => state['price'] as double)
  //         .toList()
  //       ..sort((a, b) => b.compareTo(a)); // Descending order

  //     int count = prices.length < 10 ? prices.length : 10;
  //     double averagePrice = count > 0
  //         ? prices.sublist(0, count).reduce((a, b) => a + b) / count
  //         : 0.0;

  //     // print("5");
  //     // Step 4: Fetch product IDs from the products collection
  //     Set<String> productIds = {};
  //     for (var state in statesList) {
  //       print(state);
  //       final productQuery = await firestore
  //           .collection('products')
  //           .where('state', isEqualTo: state['state'])
  //           .get();

  //       for (var product in productQuery.docs) {
  //         final productData = product.data();

  //         // Match cropName in multiple fields
  //         if ((productData['name'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true ||
  //             (productData['description'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true ||
  //             (productData['highlights']
  //                     ?.toString()
  //                     .toLowerCase()
  //                     .contains(cropName.toLowerCase()) ??
  //                 false) ||
  //             (productData['variant']
  //                     ?.toString()
  //                     .toLowerCase()
  //                     .contains(cropName.toLowerCase()) ??
  //                 false) ||
  //             (productData['seed_company'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true) {
  //           productIds.add(product.id);
  //         }
  //       }
  //     }
  //     // print("7");

  //     return {
  //       'product_ids': productIds.toList(),
  //       'average_price': averagePrice,
  //     };
  //   } catch (e) {
  //     print("Error fetching product IDs and price: $e");
  //     return {
  //       'product_ids': [],
  //       'average_price': 0.0,
  //     };
  //   }
  // }

  // Future<Map<String, dynamic>> fetchProductIdsAndPrice({
  //   String? cropName,
  //   String? category,
  // }) async {
  //   // Static map for categories
  //   const Map<String, List<String>> cropCategories = {
  //     'fruits': ['banana', 'orange'],
  //     'vegetables': ['cauliflower', 'onion', 'potato', 'tomato'],
  //     'grains': ['rice', 'wheat'],
  //   };

  //   try {
  //     print("cATEGORY $category");
  //     if (category != null && cropCategories.containsKey(category)) {
  //       // Retrieve crops from the category
  //       List<String> crops =
  //           (cropCategories[category] as List<dynamic>).cast<String>();

  //       print(crops);

  //       Set<String> productIds = {};

  //       for (var crop in crops) {
  //         print(crop);
  //         final cropResult = await _fetchCropDetails(crop);
  //         productIds.addAll(cropResult['product_ids'] ?? []);
  //       }

  //       return {
  //         'product_ids': productIds.toList(),
  //         'average_price': 0.0, // Placeholder: Compute average if required
  //       };
  //     } else if (cropName != null) {
  //       // Use the existing logic for a specific crop name
  //       return await _fetchCropDetails(cropName);
  //     } else {
  //       throw Exception("Either cropName or category must be provided");
  //     }
  //   } catch (e) {
  //     print("Error fetching product IDs and price: $e");
  //     return {
  //       'product_ids': [],
  //       'average_price': 0.0,
  //     };
  //   }
  // }

// Helper function to fetch crop details based on cropName
  // Future<Map<String, dynamic>> _fetchCropDetails(String cropName) async {
  //   try {
  //     final cropDoc =
  //         await firestore.collection('crops-demand').doc(cropName).get();

  //     if (!cropDoc.exists) {
  //       throw Exception("Crop document not found");
  //     }

  //     print("Crop document found.");

  //     Map<String, dynamic> cropData = cropDoc.data() ?? {};
  //     Map<String, dynamic> statesData = cropData['states'] ?? {};

  //     List<Map<String, dynamic>> statesList = [];
  //     for (var entry in statesData.entries) {
  //       final stateName = entry.key;
  //       final stateData = entry.value;

  //       if (stateData is Map<String, dynamic>) {
  //         statesList.add({
  //           'state': stateName,
  //           'production': (stateData['production'] as num?)?.toDouble() ?? 0.0,
  //           'demand': (stateData['demand'] as num?)?.toDouble() ?? 0.0,
  //           'price': (stateData['price'] as num?)?.toDouble() ?? 0.0,
  //         });
  //       } else {
  //         print("Invalid data for state: $stateName");
  //       }
  //     }

  //     // Sort states by production-demand difference
  //     statesList.sort((a, b) {
  //       double demandDiffA = a['production'] - a['demand'];
  //       double demandDiffB = b['production'] - b['demand'];
  //       return demandDiffB.compareTo(demandDiffA);
  //     });

  //     // Calculate average price
  //     List<double> prices = statesList
  //         .map((state) => (state['price'] as num?)?.toDouble() ?? 0.0)
  //         .toList()
  //       ..sort((a, b) => b.compareTo(a));

  //     int count = prices.length < 10 ? prices.length : 10;
  //     double averagePrice = count > 0
  //         ? prices.sublist(0, count).reduce((a, b) => a + b) / count
  //         : 0.0;

  //     print("Average price calculated: $averagePrice");

  //     // Fetch product IDs and their corresponding prices
  //     List<Map<String, dynamic>> productsWithPrice = [];

  //     for (var state in statesList) {
  //       final productQuery = await firestore
  //           .collection('products')
  //           .where('state', isEqualTo: state['state'])
  //           .get();

  //       for (var product in productQuery.docs) {
  //         final productData = product.data();
  //         double productPrice =
  //             (productData['price'] as num?)?.toDouble() ?? 0.0;

  //         // Check crop name match in multiple fields
  //         if ((productData['name'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true ||
  //             (productData['description'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true ||
  //             (productData['highlights']
  //                     ?.toString()
  //                     .toLowerCase()
  //                     .contains(cropName.toLowerCase()) ??
  //                 false) ||
  //             (productData['variant']
  //                     ?.toString()
  //                     .toLowerCase()
  //                     .contains(cropName.toLowerCase()) ??
  //                 false) ||
  //             (productData['seed_company'] as String?)
  //                     ?.toLowerCase()
  //                     .contains(cropName.toLowerCase()) ==
  //                 true) {
  //           productsWithPrice.add({
  //             'product_id': product.id,
  //             'product_price': productPrice,
  //           });
  //         }
  //       }
  //     }

  //     print("Products with price: $productsWithPrice");

  //     return {
  //       'products': productsWithPrice,
  //       'average_price': averagePrice,
  //     };
  //   } catch (e) {
  //     print("Error fetching crop details: $e");
  //     return {
  //       'products': [],
  //       'average_price': 0.0,
  //     };
  //   }
  // }

  Future<List<String>> searchInProductsByCategory(String category) async {
    // Create a reference to the products collection
    final queryRef = firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .where('category', isEqualTo: category); // Query by category

    // Fetch the documents that match the query
    final querySnapshot = await queryRef.get();

    // Extract the product IDs from the documents
    List<String> productIds = [];
    for (final doc in querySnapshot.docs) {
      productIds.add(doc.id); // Add the document ID to the list
    }

    return productIds; // Return the list of product IDs
  }

  Future<bool> addProductReview(String productId, Review review) async {
    final reviewCollectionRef = firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .doc(productId)
        .collection(REVIEWS_COLLECTION_NAME);
    final reviewDoc = reviewCollectionRef.doc(review.reviewerUid);
    if ((await reviewDoc.get()).exists == false) {
      await reviewDoc.set(review.toMap());
      return await addUsersRatingForProduct(productId, review.rating);
    } else {
      final docData = await reviewDoc.get();
      final int oldRating = docData.data()![Product.RATING_KEY];
      await reviewDoc.update(review.toUpdateMap());
      return await addUsersRatingForProduct(productId, review.rating,
          oldRating: oldRating);
    }
  }

  Future<bool> addUsersRatingForProduct(String productId, int rating,
      {int? oldRating}) async {
    final productDocRef =
        firestore.collection(PRODUCTS_COLLECTION_NAME).doc(productId);
    final ratingsCount =
        (await productDocRef.collection(REVIEWS_COLLECTION_NAME).get())
            .docs
            .length;
    final productDoc = await productDocRef.get();
    final prevRating = productDoc.data()![Review.RATING_KEY];
    double newRating;
    if (oldRating == null) {
      newRating = (prevRating * (ratingsCount - 1) + rating) / ratingsCount;
    } else {
      newRating =
          (prevRating * (ratingsCount) + rating - oldRating) / ratingsCount;
    }
    final newRatingRounded = double.parse(newRating.toStringAsFixed(1));
    await productDocRef.update({Product.RATING_KEY: newRatingRounded});
    return true;
  }

  Future<Review?> getProductReviewWithID(
      String productId, String reviewId) async {
    final reviewCollectionRef = firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .doc(productId)
        .collection(REVIEWS_COLLECTION_NAME);
    final reviewDoc = await reviewCollectionRef.doc(reviewId).get();
    if (reviewDoc.exists) {
      return Review.fromMap(reviewDoc.data()!, id: reviewDoc.id);
    }
    return null;
  }

  Stream<List<Review>> getAllReviewsStreamForProductId(
      String productId) async* {
    final reviewQuerySnapshot = firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .doc(productId)
        .collection(REVIEWS_COLLECTION_NAME)
        .snapshots();

    await for (final querySnapshot in reviewQuerySnapshot) {
      List<Review> reviews = [];
      for (final reviewDoc in querySnapshot.docs) {
        Review review = Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
        reviews.add(review);
      }
      yield reviews;
    }
  }

  Future<Product>? getProductWithID(String? productId) async {
    final docSnapshot = await firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .doc(productId)
        .get();

    if (docSnapshot.exists) {
      return Product.fromMap(docSnapshot.data()!, id: docSnapshot.id);
    }
    return Product(
      "",
      position: Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );
  }

  Future<String> addUsersProduct(Product product) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not logged in");
    }
    product.owner = uid;
    // final productMap = product.toMap();
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    final docRef = await productsCollectionReference.add(product.toMap());
    await docRef.update({});
    return docRef.id;
  }

  Future<bool> deleteUserProduct(String productId) async {
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    await productsCollectionReference.doc(productId).delete();
    return true;
  }

  Future<String> updateUsersProduct(Product product) async {
    final productMap = product.toUpdateMap();
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    final docRef = productsCollectionReference.doc(product.id);
    await docRef.update(productMap);
    if (product.productType != null) {
      await docRef.update({
        // Product.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
        //     [productMap[Product.PRODUCT_TYPE_KEY].toString().toLowerCase()])
      });
    }
    return docRef.id;
  }

  Future<List<String>> getCategoryProductsList(String category) async {
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    final queryResult = await productsCollectionReference
        .where(Product.CATEGORY_KEY, isEqualTo: category)
        .get();
    List<String> productsId = [];
    for (final product in queryResult.docs) {
      final id = product.id;
      productsId.add(id);
    }
    return productsId;
  }

  // Future<List<String>> getCategoryProductsList(ProductType productType) async {
  //   final productsCollectionReference =
  //       firestore.collection(PRODUCTS_COLLECTION_NAME);
  //   final queryResult = await productsCollectionReference
  //       .where(Product.PRODUCT_TYPE_KEY,
  //           isEqualTo: EnumToString.convertToString(productType))
  //       .get();
  //   List<String> productsId = [];
  //   for (final product in queryResult.docs) {
  //     final id = product.id;
  //     productsId.add(id);
  //   }
  //   return productsId;
  // }

  Future<List<String>> get usersProductsList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not logged in");
    }
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    final querySnapshot = await productsCollectionReference
        .where(Product.OWNER_KEY, isEqualTo: uid)
        .get();
    List<String> usersProducts = [];
    for (final doc in querySnapshot.docs) {
      usersProducts.add(doc.id);
    }
    return usersProducts;
  }

  Future<List<String>> get allProductsList async {
    final products = await firestore.collection(PRODUCTS_COLLECTION_NAME).get();
    List<String> productsId = [];
    for (final product in products.docs) {
      final id = product.id;
      productsId.add(id);
    }

    return productsId;
  }
  // Future<List<String>> get allProductsList async {
  //   final products = await firestore.collection(PRODUCTS_COLLECTION_NAME).get();
  //   List<String> productsId = [];
  //   for (final product in products.docs) {
  //     final id = product.id;
  //     productsId.add(id);
  //   }
  //   return productsId;
  // }

  Future<List<Product>> getBestSearchProducts() async {
    final productsSnapshot =
        await firestore.collection(PRODUCTS_COLLECTION_NAME).get();
    List<Product> products = [];

    for (final doc in productsSnapshot.docs) {
      final product = Product.fromMap(doc.data(), id: doc.id);
      products.add(product);
    }

    products.sort((a, b) => (b.pointRating ?? 0).compareTo(a.pointRating ?? 0));
    return products;
  }

  Future<List<Product>> getProductsByCategoryAndRating(String category) async {
    final productsSnapshot = await firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .where('category', isEqualTo: category) // Filter by category
        .get();
    List<Product> products = [];

    for (final doc in productsSnapshot.docs) {
      final product = Product.fromMap(doc.data(), id: doc.id);
      products.add(product);
    }

    // Sort the products by their pointRating in descending order
    products.sort((a, b) => (b.pointRating ?? 0).compareTo(a.pointRating ?? 0));

    return products;
  }

  Future<List<Product>> getNearbyProducts(String category) async {
    // Fetch the current user's location dynamically
    Position userLocation = await determinePosition();

    print(userLocation);

    final productsSnapshot = await firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .where('category', isEqualTo: category) // Filter by category
        .get();
    List<Product> products = [];

    for (final doc in productsSnapshot.docs) {
      final product = Product.fromMap(doc.data(), id: doc.id);
      products.add(product);
    }

    // Sort products based on distance from user location
    products.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        a.position.latitude,
        a.position.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        b.position.latitude,
        b.position.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return products;
  }

  // Method to determine the current position of the user
  Future<Position> determinePosition() async {
    if (userLocation != null) {
      return userLocation!; // Return stored location if available
    }

    print(1);

    bool serviceEnabled;
    LocationPermission permission;
    print(2);

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    print(3);

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permissions are denied');
      }
    }

    print(4);
    // When we reach here, permissions are granted, and we can get the location
    userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(5);
    return userLocation!;
  }

  Future<bool> updateProductsImages(
      String productId, List<String> imgUrl) async {
    final Product updateProduct = Product(
      productId,
      images: imgUrl,
      position: Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );
    final docRef =
        firestore.collection(PRODUCTS_COLLECTION_NAME).doc(productId);
    await docRef.update(updateProduct.toUpdateMap());
    return true;
  }

  String getPathForProductImage(String id, int index) {
    return "products/images/${id}_$index";
  }

  // Implement this method to fetch the current user
  Future<User> getCurrentUser() async {
    // Fetch the user from Firestore or wherever you store user data
    // This is just a placeholder; implement your logic to get the current user
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('currentUserId')
        .get();
    return User.fromFirestore(userDoc);
  }

  Future<Position> getProductLocation(String productId) async {
    final doc = await firestore
        .collection(PRODUCTS_COLLECTION_NAME)
        .doc(productId)
        .get();
    final data = doc.data();
    if (data != null && data['position'] != null) {
      // Assuming position is stored as GeoPoint
      GeoPoint geoPoint = data['position'];
      print("");
      return Position(
          latitude: geoPoint.latitude,
          longitude: geoPoint.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0);
    }
    throw Exception('Product location not found');
  }

  double calculateDistance(Position userLocation, Position productLocation) {
    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      productLocation.latitude,
      productLocation.longitude,
    );
  }
}
