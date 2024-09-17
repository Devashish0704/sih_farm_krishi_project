import 'package:e_commerce_app_flutter/models/Product.dart';

import 'package:flutter/material.dart';

import 'components/body.dart';

class CategoryProductsScreen extends StatelessWidget {
  final ProductType productType;

  const CategoryProductsScreen({
    required this.productType,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        productType: productType,
      ),
    );
  }
}
