import 'dart:async';

import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../utils.dart';
import '../components/home_header.dart';
import 'product_type_box.dart';
import 'products_section.dart';
import 'product_categories.dart';

class BestSearchProductsStream extends DataStream<List<String>> {
  @override
  void reload() async {
    try {
      final bestSearchProducts =
          await ProductDatabaseHelper().getBestSearchProducts();
      addData(bestSearchProducts.map((product) => product.id).toList());
    } catch (e) {
      addError(e);
    }
  }
}

class NearbyProductsStream extends DataStream<List<String>> {
  @override
  void reload() async {
    try {
      final nearbyProducts = await ProductDatabaseHelper().getNearbyProducts();
      addData(nearbyProducts.map((product) => product.id).toList());
    } catch (e) {
      addError(e);
    }
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final FavouriteProductsStream favouriteProductsStream =
      FavouriteProductsStream();
  final AllProductsStream allProductsStream = AllProductsStream();

  final BestSearchProductsStream bestSearchProductsStream =
      BestSearchProductsStream();
  final NearbyProductsStream nearbyProductsStream = NearbyProductsStream();

  bool isBestSearch = false; // Toggle state

  @override
  void initState() {
    super.initState();
    favouriteProductsStream.init();
    allProductsStream.init();
    bestSearchProductsStream.init();
    nearbyProductsStream.init();
  }

  @override
  void dispose() {
    favouriteProductsStream.dispose();
    allProductsStream.dispose();
    bestSearchProductsStream.dispose();
    nearbyProductsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.length <= 0) return;
                    List<String> searchedProductsId;
                    try {
                      searchedProductsId = await ProductDatabaseHelper()
                          .searchInProducts(query.toLowerCase());
                      if (searchedProductsId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultProductsId: searchedProductsId,
                              searchIn: "All Products",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Couldn't perform search due to some unknown reason";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$error"),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
                    bool allowed =
                        AuthentificationService().currentUserVerified;
                    if (!allowed) {
                      final reverify = await showConfirmationDialog(context,
                          "You haven't verified your email address. This action is only allowed for verified users.",
                          positiveResponse: "Resend verification email",
                          negativeResponse: "Go back");
                      if (reverify) {
                        final future = AuthentificationService()
                            .sendVerificationEmailToCurrentUser();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AsyncProgressDialog(
                              future,
                              message: Text("Resending verification email"),
                            );
                          },
                        );
                      }
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...List.generate(
                          productCategories.length,
                          (index) {
                            return ProductTypeBox(
                              icon: productCategories[index][ICON_KEY],
                              title: productCategories[index][TITLE_KEY],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryProductsScreen(
                                      productType: productCategories[index]
                                          [PRODUCT_TYPE_KEY],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),

                // Add toggle button and text here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: isBestSearch,
                      onChanged: (value) {
                        setState(() {
                          isBestSearch = value;
                          if (isBestSearch) {
                            bestSearchProductsStream.reload();
                          } else {
                            nearbyProductsStream.reload();
                          }
                        });
                      },
                    ),
                    Text(
                      isBestSearch ? "Best Search Enabled" : "Nearby Products",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(5),
                  child: Text(
                    isBestSearch
                        ? "Switch for nearby products"
                        : "Switch for best search",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(20)),

                SizedBox(
                  height: SizeConfig.screenHeight * 0.8,
                  child: ProductsSection(
                    sectionTitle: isBestSearch
                        ? "Best Rated Products"
                        : "Nearby Products",
                    productsStreamController: isBestSearch
                        ? bestSearchProductsStream
                        : nearbyProductsStream,
                    emptyListMessage: isBestSearch
                        ? "No highly rated products available"
                        : "No nearby products available",
                    onProductCardTapped: onProductCardTapped,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouriteProductsStream.reload();
    allProductsStream.reload();
    return Future<void>.value();
  }

  void onProductCardTapped(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: productId),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
}
