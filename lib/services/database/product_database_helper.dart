import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/farmer/models/User.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
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

  Future<List<String>> searchInProducts(String query,
      {ProductType? productType}) async {
    Query<Map<String, dynamic>> queryRef;
    if (productType == null) {
      queryRef = firestore.collection(PRODUCTS_COLLECTION_NAME);
    } else {
      final productTypeStr = EnumToString.convertToString(productType);
      queryRef = firestore
          .collection(PRODUCTS_COLLECTION_NAME)
          .where(Product.PRODUCT_TYPE_KEY, isEqualTo: productTypeStr);
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
      final product = Product.fromMap(doc.data(), id: doc.id);
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

  Future<List<String>> getCategoryProductsList(ProductType productType) async {
    final productsCollectionReference =
        firestore.collection(PRODUCTS_COLLECTION_NAME);
    final queryResult = await productsCollectionReference
        .where(Product.PRODUCT_TYPE_KEY,
            isEqualTo: EnumToString.convertToString(productType))
        .get();
    List<String> productsId = [];
    for (final product in queryResult.docs) {
      final id = product.id;
      productsId.add(id);
    }
    return productsId;
  }

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

  Future<List<Product>> getNearbyProducts() async {
    // Fetch the current user's location dynamically
    Position userLocation = await _determinePosition();

    print(userLocation);

    final productsSnapshot =
        await firestore.collection(PRODUCTS_COLLECTION_NAME).get();
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
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return a default position or handle accordingly
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permissions are denied, handle accordingly
        throw Exception('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted, and we can get the location
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
}
