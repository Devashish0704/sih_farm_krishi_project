import 'dart:async';
import 'dart:io';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import './ProductsState.dart';

class ProductsBloc {
  bool userOnly;
  String? userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final StreamController<ProductsState> _stateController =
      StreamController<ProductsState>.broadcast();

  ProductsBloc({String? userId, bool fetchProducts = true})
      : userOnly = userId != null {
    if (fetchProducts) {
      if (userOnly) {
        _fetchUserProducts(userId!);
      } else {
        _fetchAllProducts();
      }
    }
  }

  Future<void> _fetchAllProducts() async {
    try {
      print("fetching all");
      final res = await _db.collection('products').get();

      if (res.docs.isEmpty) {
        print("No documents found");
      }

      final List<Product> products = res.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();

      _setState(ProductsState.onSuccess(products));
    } catch (e) {
      print("Error occurred: $e"); // Log error
      _setState(ProductsState.onError(e.toString()));
    }
  }

  Future<void> _fetchUserProducts(String userId) async {
    try {
      print(userId);
      final res = await _db
          .collection('products')
          .where('userId', isEqualTo: userId)
          .get();
      final List<Product> userProducts =
          res.docs.map((doc) => Product.fromFirestore(doc)).toList();
      print(userProducts);
      _setState(ProductsState.onSuccess(userProducts));
    } catch (e) {
      print(e);
      _setState(ProductsState.onError(e.toString()));
    }
  }

  Future<void> fetchProduct(String id, Function(Product) callback) async {
    try {
      final doc = await _db.collection('products').doc(id).get();
      final product = Product.fromFirestore(doc);
      print(product);
      callback(product);
      _setState(ProductsState.onProductSuccess());
    } catch (e) {
      _setState(ProductsState.onError(e.toString()));
    }
  }

  Future<void> addProduct(
      Product product, File image, Function() callback) async {
    try {
      _setState(ProductsState.onRequest());
      final ref = _storage.ref().child('products/${Path.basename(image.path)}');
      print(ref);
      final uploadTask = ref.putFile(image);
      await uploadTask.whenComplete(() {});
      final user = await _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      //  product.userId = user.uid;
      product.phoneNumber = user.phoneNumber!;
      //  product.imageUrl = await ref.getDownloadURL();
      await _db.collection('products').add(product.toJson());
      _setState(ProductsState.onProductSuccess());
      callback();
    } catch (e) {
      _setState(ProductsState.onError(e.toString()));
    }
  }

  Future<void> updateProduct(
      String id, Product product, File? image, Function() callback) async {
    try {
      _setState(ProductsState.onRequest());
      if (image != null) {
        final ref =
            _storage.ref().child('products/${Path.basename(image.path)}');
        final uploadTask = ref.putFile(image);
        await uploadTask.whenComplete(() {});
        //    product.imageUrl = await ref.getDownloadURL();
      }
      final user = await _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      //  product.userId = user.uid;
      product.phoneNumber = user.phoneNumber!;
      await _db.collection('products').doc(id).update(product.toJson());
      _setState(ProductsState.onProductSuccess());
      callback();
    } catch (e) {
      _setState(ProductsState.onError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      _setState(ProductsState.onRequest());
      await _db.collection('products').doc(id).delete();
      _setState(ProductsState.onProductSuccess());
      refresh();
    } catch (e) {
      _setState(ProductsState.onError(e.toString()));
    }
  }

  void _setState(ProductsState state) {
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void refresh() {
    print("is refreshing");
    if (userOnly && userId != null) {
      _fetchUserProducts(userId!);
    } else {
      _fetchAllProducts();
    }
  }

  void dispose() {
    _stateController.close();
  }

  Stream<ProductsState> get state => _stateController.stream;
}
