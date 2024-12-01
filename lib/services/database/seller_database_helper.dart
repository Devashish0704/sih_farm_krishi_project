import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';

class SellerDatabaseHelper {
  static const String PRODUCTS_COLLECTION_NAME = "products";
  // static const String SELLER_PRODUCTS_COLLECTION_NAME = "seller_products";

  SellerDatabaseHelper._privateConstructor();
  static final SellerDatabaseHelper _instance =
      SellerDatabaseHelper._privateConstructor();
  factory SellerDatabaseHelper() => _instance;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Get seller's order history (products sold by this seller)
  Future<List<OrderedProduct>> getSellerOrders() async {
    final uid = AuthentificationService().currentUser!.uid;
    print(uid);

    // Query all ordered products where the seller ID matches current user
    final ordersSnapshot = await _firebaseFirestore
        .collection('ordered_products')
        .where('seller_id', isEqualTo: uid)
        .get();

    print(ordersSnapshot.docs
        .map((doc) => OrderedProduct.fromMap(doc.data(), id: doc.id))
        .toList());

    return ordersSnapshot.docs
        .map((doc) => OrderedProduct.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // Get total revenue for seller's products
  Future<num> getSellerTotalRevenue() async {
    final uid = AuthentificationService().currentUser!.uid;

    final ordersSnapshot = await _firebaseFirestore
        .collectionGroup('ordered_products')
        .where('sellerId', isEqualTo: uid)
        .get();

    return ordersSnapshot.docs.fold<num>(0, (total, doc) {
      final orderData = doc.data();
      return total + (orderData['price'] ?? 0) * (orderData['quantity'] ?? 0);
    });
  }
}
