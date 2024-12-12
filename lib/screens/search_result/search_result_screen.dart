import 'package:flutter/material.dart';

import 'components/body.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final String productPrice;
  final List<String> searchResultProductsId;

  const SearchResultScreen({
    required this.searchQuery,
    required this.searchResultProductsId,
    required this.searchIn, required this.productPrice,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BodyForSearchResult(
        searchQuery: searchQuery,
        searchResultProductsId: searchResultProductsId,
        searchIn: searchIn, price: productPrice,
      ),
    );
  }
}
