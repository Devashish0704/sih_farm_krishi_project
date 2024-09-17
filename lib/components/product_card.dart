import 'package:e_commerce_app_flutter/farmer/routing/Application.dart';
import 'package:e_commerce_app_flutter/farmer/screens/ProductsScreen/state/ProductsBloc.dart';
import 'package:e_commerce_app_flutter/farmer/widgets/ConfirmationDialog.dart';
import 'package:e_commerce_app_flutter/farmer/widgets/CustomYellowButton.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';

import '../farmer/services/Helpers.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final bool userOnly;
  final bool isEnglish;
  final GestureTapCallback press;
  const ProductCard({
    required this.productId,
    required this.press,
    this.userOnly = false,
    this.isEnglish = true,
  });

  void _deleteProductConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        () => Provider.of<ProductsBloc>(context, listen: false)
            .deleteProduct(productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kTextColor.withOpacity(0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder<Product>(
            future: ProductDatabaseHelper().getProductWithID(productId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final Product product = snapshot.data!;
                return buildProductCardItems(product, context);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                Logger().e(error);
              }
              return Center(
                child: Icon(
                  Icons.error,
                  color: kTextColor,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Column buildProductCardItems(Product product, BuildContext context) {
    print(product);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              product.images != null
                  ? product.images![0]
                  : "https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg",
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 10),
        Flexible(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  "${product.title}\n",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 5,
                      child: Text.rich(
                        TextSpan(
                          text: "\₹${product.price}\n",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: "\₹${product.price! + 100}",
                              style: TextStyle(
                                color: kTextColor,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/DiscountTag.svg",
                            color: kPrimaryColor,
                          ),
                          Center(
                            child: Text(
                              "${0}%\nOff",
                              //   "${product.calculatePercentageDiscount()}%\nOff",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: () => Helpers.mapForDestination(
                        product.position.latitude,
                        product.position.longitude,
                      ),
                  child: Text("Go to Location")),
              userOnly
                  ? _editButtonsRow(context, product, isEnglish)
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _viewButtonsRow(
      BuildContext context, Product product, bool isEnglish) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomYellowButton(
            text: isEnglish ? 'Call' : 'संपर्क',
            icon: Icons.chat,
            onPress: () {},
          ),
          CustomYellowButton(
            text: isEnglish ? 'Location' : 'स्थान',
            icon: Icons.my_location,
            onPress: () => Helpers.mapForDestination(
              product.position.latitude,
              product.position.longitude,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editButtonsRow(
      BuildContext context, Product product, bool isEnglish) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomYellowButton(
              text: isEnglish ? 'Edit' : 'संपादित करें',
              icon: FontAwesomeIcons.edit,
              onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(
                      productToEdit: product,
                    ),
                  ))),
          CustomYellowButton(
            text: isEnglish ? 'Delete' : 'मिटाओ',
            icon: FontAwesomeIcons.trash,
            onPress: () => _deleteProductConfirmation(context),
          ),
        ],
      ),
    );
  }
}
