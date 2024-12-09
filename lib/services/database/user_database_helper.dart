import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/farmer/models/User.dart';
import 'package:e_commerce_app_flutter/models/Address.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  static const String CART_COLLECTION_NAME = "cart";
  static const String ORDERED_PRODUCTS_COLLECTION_NAME = "ordered_products";

  static const String PHONE_KEY = 'phone';
  static const String DP_KEY = "display_picture";
  static const String FAV_PRODUCTS_KEY = "favourite_products";

  UserDatabaseHelper._privateConstructor();
  static final UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() => _instance;

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firebaseFirestore;

  Future<void> createNewUser(String uid) async {
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      DP_KEY: null,
      PHONE_KEY: null,
      FAV_PRODUCTS_KEY: <String>[],
    });
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser!.uid;
    final docRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final cartCollectionRef = docRef.collection(CART_COLLECTION_NAME);
    final addressCollectionRef = docRef.collection(ADDRESSES_COLLECTION_NAME);
    final ordersCollectionRef =
        docRef.collection(ORDERED_PRODUCTS_COLLECTION_NAME);

    final cartDocs = await cartCollectionRef.get();
    for (final cartDoc in cartDocs.docs) {
      await cartCollectionRef.doc(cartDoc.id).delete();
    }
    final addressesDocs = await addressCollectionRef.get();
    for (final addressDoc in addressesDocs.docs) {
      await addressCollectionRef.doc(addressDoc.id).delete();
    }
    final ordersDocs = await ordersCollectionRef.get();
    for (final orderDoc in ordersDocs.docs) {
      await ordersCollectionRef.doc(orderDoc.id).delete();
    }

    await docRef.delete();
  }

  Future<bool> isProductFavourite(String productId) async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    final userDocData = userDocSnapshot.data();
    final favList =
        userDocData?[FAV_PRODUCTS_KEY]?.cast<String>() ?? <String>[];
    return favList.contains(productId);
  }

  Future<List<String>> get usersFavouriteProductsList async {
    final uid = AuthentificationService().currentUser!.uid;
    // print(uid);
    final userDocSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    // print(userDocSnapshot);
    final userDocData = userDocSnapshot.data();
    // print(userDocData);
    final favList = (userDocData?[FAV_PRODUCTS_KEY] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList() ??
        <String>[];
    // final favList =
    //     userDocData?[FAV_PRODUCTS_KEY] as List<String>? ?? <String>[];
    //print("favv list $favList");
    return favList;
  }

  Future<bool> switchProductFavouriteStatus(
      String productId, bool newState) async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);

    if (newState) {
      await userDocRef.update({
        FAV_PRODUCTS_KEY: FieldValue.arrayUnion([productId])
      });
    } else {
      await userDocRef.update({
        FAV_PRODUCTS_KEY: FieldValue.arrayRemove([productId])
      });
    }
    return true;
  }

  Future<List<String>> get addressesList async {
    final uid = AuthentificationService().currentUser!.uid;
    final snapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Address> getAddressFromId(String id) async {
    final uid = AuthentificationService().currentUser!.uid;
    final doc = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(id)
        .get();
    return Address.fromMap(doc.data()!, id: doc.id);
  }

  Future<bool> addAddressForCurrentUser(Address address) async {
    final uid = AuthentificationService().currentUser!.uid;
    final addressesCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME);
    await addressesCollectionRef.add(address.toMap());
    return true;
  }

  Future<bool> deleteAddressForCurrentUser(String id) async {
    final uid = AuthentificationService().currentUser!.uid;
    final addressDocRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(id);
    await addressDocRef.delete();
    return true;
  }

  Future<bool> updateAddressForCurrentUser(Address address) async {
    final uid = AuthentificationService().currentUser!.uid;
    final addressDocRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(address.id);
    await addressDocRef.update(address.toMap());
    return true;
  }

  Future<CartItem> getCartItemFromId(String id) async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docSnapshot = await cartCollectionRef.doc(id).get();
    return CartItem.fromMap(docSnapshot.data()!, id: docSnapshot.id);
  }

  Future<bool> addProductToCart(String productId, int quantity) async {
    final uid = AuthentificationService().currentUser!.uid;
    print(uid);
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(productId);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      await docRef.set(CartItem(itemCount: quantity, id: productId).toMap());
    } else {
      await docRef.update({CartItem.ITEM_COUNT_KEY: quantity});
    }
    return true;
  }
  // Future<bool> addProductToCart(String productId , ) async {
  //   final uid = AuthentificationService().currentUser!.uid;
  //   print(uid);
  //   final cartCollectionRef = firestore
  //       .collection(USERS_COLLECTION_NAME)
  //       .doc(uid)
  //       .collection(CART_COLLECTION_NAME);
  //   final docRef = cartCollectionRef.doc(productId);
  //   final docSnapshot = await docRef.get();
  //   if (!docSnapshot.exists) {
  //     await docRef.set(CartItem(itemCount: 1, id: productId).toMap());
  //   } else {
  //     await docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
  //   }
  //   return true;
  // }

  Future<List<Map>> emptyCart() async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartItems = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME)
        .get();

    final orderedProducts = <Map>[];
    num total = 0.0;

    for (final doc in cartItems.docs) {
      num ptotal = 0.0;
      print(doc.data());
      print("doc " + doc.id);
      final itemsCount = doc.data()[CartItem.ITEM_COUNT_KEY] as num;
      final product = await ProductDatabaseHelper().getProductWithID(doc.id);
      ptotal += (itemsCount * product!.price!);
      total += ptotal;
      orderedProducts.add({
        "id": doc.id,
        "count": doc.data()[CartItem.ITEM_COUNT_KEY],
        "total": ptotal,
      });
      await doc.reference.delete();
    }
    return orderedProducts;
  }
  // Future<List<String>> emptyCart() async {
  //   final uid = AuthentificationService().currentUser!.uid;
  //   final cartItems = await firestore
  //       .collection(USERS_COLLECTION_NAME)
  //       .doc(uid)
  //       .collection(CART_COLLECTION_NAME)
  //       .get();

  //   final orderedProductsUid = <String>[];
  //   print(cartItems.docs);
  //   print(cartItems.docs);
  //   for (final doc in cartItems.docs) {
  //     print(doc.data());
  //     print("doc " + doc.id);
  //     orderedProductsUid.add(doc.id);
  //     await doc.reference.delete();
  //   }
  //   return orderedProductsUid;
  // }

  Future<num> get cartTotal async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartItems = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME)
        .get();
    num total = 0.0;
    for (final doc in cartItems.docs) {
      final itemsCount = doc.data()[CartItem.ITEM_COUNT_KEY] as num;
      final product = await ProductDatabaseHelper().getProductWithID(doc.id);
      total += (itemsCount * product!.price!);
    }
    return total;
  }

  Future<bool> removeProductFromCart(String cartItemID) async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    await cartCollectionRef.doc(cartItemID).delete();
    return true;
  }

  Future<bool> increaseCartItemCount(String cartItemID) async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    await docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    return true;
  }

  Future<bool> decreaseCartItemCount(String cartItemID) async {
    final uid = AuthentificationService().currentUser!.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    final docSnapshot = await docRef.get();
    final currentCount =
        docSnapshot.data()?[CartItem.ITEM_COUNT_KEY] as int? ?? 0;
    if (currentCount <= 1) {
      return removeProductFromCart(cartItemID);
    } else {
      await docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(-1)});
    }
    return true;
  }

  Future<List<String>> get allCartItemsList async {
    final uid = AuthentificationService().currentUser!.uid;
    final querySnapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME)
        .get();
    return querySnapshot.docs.map((item) => item.id).toList();
  }

  Future<List<String>> get orderedProductsList async {
    final uid = AuthentificationService().currentUser!.uid;
    print(uid);
    final orderedProductsSnapshot = await firestore
        .collection(ORDERED_PRODUCTS_COLLECTION_NAME)
        .where('buyer_id', isEqualTo: uid)
        .get();

    // print(
    //     "ordered products ${orderedProductsSnapshot.docs.map((doc) => doc.id).toList()}");
    return orderedProductsSnapshot.docs.map((doc) => doc.id).toList();
  }
  // Future<List<String>> get orderedProductsList async {
  //   final uid = AuthentificationService().currentUser!.uid;
  //   final orderedProductsSnapshot = await firestore
  //       .collection(USERS_COLLECTION_NAME)
  //       .doc(uid)
  //       .collection(ORDERED_PRODUCTS_COLLECTION_NAME)
  //       .get();
  //   return orderedProductsSnapshot.docs.map((doc) => doc.id).toList();
  // }

  Future<void> updatePaymentStatusToDone(String orderedProductId) async {
    final uid = AuthentificationService().currentUser!.uid;

    await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ORDERED_PRODUCTS_COLLECTION_NAME)
        .doc(orderedProductId)
        .update({
          OrderedProduct.PAYMENT_STATUS_KEY: "DONE",
        })
        .then((value) => print("Payment status updated to DONE"))
        .catchError(
            (error) => print("Failed to update payment status: $error"));
  }

  Future<bool> addToMyOrders(List<OrderedProduct> orders) async {
    final uid = AuthentificationService().currentUser!.uid;
    print(uid);
    final orderedProductsCollectionRef =
        firestore.collection(ORDERED_PRODUCTS_COLLECTION_NAME);

    for (final order in orders) {
      order.buyerId = uid;
      final product =
          await ProductDatabaseHelper().getProductWithID(order.productUid);
      String? sellerId;
      if (product != null) {
        sellerId = product.owner;
      }

      order.sellerId = sellerId;
      print(order.buyerId);
      print(order.sellerId);
      // final orderData1 = order.toMap()..['buyerId'] = uid;
      // final orderData = orderData1..['sellerId'] = sellerId;
      print("odereing product $order");
      await orderedProductsCollectionRef.add(order.toMap());
    }
    return true;
  }
  // Future<bool> addToMyOrders(List<OrderedProduct> orders) async {
  //   final uid = AuthentificationService().currentUser!.uid;
  //   final orderedProductsCollectionRef = firestore
  //       .collection(USERS_COLLECTION_NAME)
  //       .doc(uid)
  //       .collection(ORDERED_PRODUCTS_COLLECTION_NAME);
  //   for (final order in orders) {
  //     await orderedProductsCollectionRef.add(order.toMap());
  //   }
  //   return true;
  // }

  // Future<bool> addToOrderedProducts(List<OrderedProduct> orders) async {
  //   final uid = AuthentificationService().currentUser!.uid;
  //   final orderedProductsCollectionRef = firestore
  //       .collection(ORDERED_PRODUCTS_COLLECTION_NAME)
  //       .doc(uid)
  //       .collection(ORDERED_PRODUCTS_COLLECTION_NAME);
  //   for (final order in orders) {
  //     await orderedProductsCollectionRef.add(order.toMap());
  //   }
  //   return true;
  // }

  Future<OrderedProduct> getOrderedProductFromId(String id) async {
    final uid = AuthentificationService().currentUser!.uid;
    final doc = await firestore
        .collection(ORDERED_PRODUCTS_COLLECTION_NAME)
        .doc(id)
        .get();
    return OrderedProduct.fromMap(doc.data()!, id: doc.id);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> get currentUserDataStream {
    final uid = AuthentificationService().currentUser!.uid;
    return firestore.collection(USERS_COLLECTION_NAME).doc(uid).snapshots();
  }

  Future<bool> updatePhoneForCurrentUser(String phone) async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocRef.update({PHONE_KEY: phone});
    return true;
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = AuthentificationService().currentUser!.uid;
    return "user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocRef.update({DP_KEY: url});
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocRef.update({DP_KEY: FieldValue.delete()});
    return true;
  }

  Future<String?> get displayPictureForCurrentUser async {
    final uid = AuthentificationService().currentUser!.uid;
    final userDocSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    return userDocSnapshot.data()?[DP_KEY] as String?;
  }

  Future<User?> getUserDetailsById(String userId) async {
    try {
      final userDoc =
          await firestore.collection(USERS_COLLECTION_NAME).doc(userId).get();
      if (userDoc.exists) {
        return User.fromMap(userDoc.data()!, userDoc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
