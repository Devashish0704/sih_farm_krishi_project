import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/screens/my_orders/components/product_review_dialog.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/ordered_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final OrderedProductsStream _orderedProductsStream = OrderedProductsStream();

  @override
  void initState() {
    super.initState();
    _orderedProductsStream.init();
  }

  @override
  void dispose() {
    _orderedProductsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "Your Orders",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.75,
                  child: _buildOrderedProductsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    _orderedProductsStream.reload();
  }

  Widget _buildOrderedProductsList() {
    return StreamBuilder<List<String>>(
      stream: _orderedProductsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          Logger().w('Error fetching ordered products: ${snapshot.error}');
          return Center(
            child: NothingToShowContainer(
              iconPath: "assets/icons/network_error.svg",
              primaryMessage: "Something went wrong",
              secondaryMessage: "Unable to connect to Database",
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: NothingToShowContainer(
              iconPath: "assets/icons/empty_bag.svg",
              secondaryMessage: "Order something to show here",
            ),
          );
        }

        final orderedProductsIds = snapshot.data!;
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: orderedProductsIds.length,
          itemBuilder: (context, index) {
            return FutureBuilder<OrderedProduct>(
              future: UserDatabaseHelper()
                  .getOrderedProductFromId(orderedProductsIds[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  Logger()
                      .e('Error fetching ordered product: ${snapshot.error}');
                  return Icon(
                    Icons.error,
                    size: 60,
                    color: kTextColor,
                  );
                } else if (!snapshot.hasData) {
                  return Icon(
                    Icons.error,
                    size: 60,
                    color: kTextColor,
                  );
                }

                final orderedProduct = snapshot.data!;
                return _buildOrderedProductItem(
                    orderedProduct, orderedProductsIds[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderedProductItem(
      OrderedProduct orderedProduct, String OrderedProductIds) {
    return FutureBuilder<Product>(
      future:
          ProductDatabaseHelper().getProductWithID(orderedProduct.productUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          Logger().e('Error fetching product: ${snapshot.error}');
          return Icon(
            Icons.error,
            size: 60,
            color: kTextColor,
          );
        } else if (!snapshot.hasData) {
          return Icon(
            Icons.error,
            size: 60,
            color: kTextColor,
          );
        }

        final product = snapshot.data!;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kTextColor.withOpacity(0.12),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    text: "Ordered on:  ",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    children: [
                      TextSpan(
                        text: orderedProduct.orderDate,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: kTextColor.withOpacity(0.15),
                    ),
                  ),
                ),
                child: ProductShortDetailCard(
                  productId: product.id,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: product.id,
                        ),
                      ),
                    ).then((_) async {
                      await _refreshPage();
                    });
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: TextButton(
                  onPressed: () async {
                    final currentUserUid =
                        AuthentificationService().currentUser!.uid;
                    Review? prevReview;
                    try {
                      prevReview = await ProductDatabaseHelper()
                          .getProductReviewWithID(
                              orderedProduct.id, currentUserUid);
                    } on FirebaseException catch (e) {
                      Logger().w("Firebase Exception: $e");
                    } catch (e) {
                      Logger().w("Unknown Exception: $e");
                    } finally {
                      prevReview ??=
                          Review(currentUserUid, reviewerUid: currentUserUid);
                    }

                    final result = await showDialog(
                      context: context,
                      builder: (context) => ProductReviewDialog(
                        review: prevReview!,
                        ProductId: OrderedProductIds,
                      ),
                    );

                    if (result is Review) {
                      String snackbarMessage = "a";
                      bool reviewAdded = false;
                      try {
                        reviewAdded = await ProductDatabaseHelper()
                            .addProductReview(product.id, result);
                        snackbarMessage = reviewAdded
                            ? "Product review added successfully"
                            : "Couldn't add product review due to unknown reason";
                      } on FirebaseException catch (e) {
                        Logger().w("Firebase Exception: $e");
                        snackbarMessage = e.toString();
                      } catch (e) {
                        Logger().w("Unknown Exception: $e");
                        snackbarMessage = e.toString();
                      } finally {
                        Logger().i(snackbarMessage);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(snackbarMessage)),
                        );
                      }
                      await _refreshPage();
                    }
                  },
                  child: Text(
                    "Give Product Review",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
