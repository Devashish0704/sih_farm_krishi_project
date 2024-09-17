import 'package:e_commerce_app_flutter/models/Product.dart';

import '../../../models/Product.dart';

class ProductsState {
  final List<Product> products;
  final Product? currentProduct; // Nullable, assuming it can be null
  final bool isLoading;
  final String? error; // Nullable, assuming it can be null

  // Named constructors for different states
  ProductsState({
    required this.products,
    this.currentProduct,
    this.isLoading = false,
    this.error,
  });

  // Factory constructor for the request state
  factory ProductsState.onRequest() {
    return ProductsState(
      products: [],
      isLoading: true,
      error: null,
    );
  }

  // Factory constructor for success state
  factory ProductsState.onSuccess(List<Product> products) {
    return ProductsState(
      products: products,
      isLoading: false,
      error: null,
    );
  }

  // Factory constructor for error state
  factory ProductsState.onError(String error) {
    return ProductsState(
      products: [],
      isLoading: false,
      error: error,
    );
  }

  // Factory constructor for product success state (e.g., after adding or updating a product)
  factory ProductsState.onProductSuccess() {
    return ProductsState(
      products: [],
      isLoading: false,
      error: null,
    );
  }
}
