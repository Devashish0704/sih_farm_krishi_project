import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app_flutter/farmer/routing/Application.dart';
import 'package:e_commerce_app_flutter/farmer/screens/ProductsScreen/state/ProductsBloc.dart';
import 'package:e_commerce_app_flutter/farmer/widgets/ConfirmationDialog.dart';
import 'package:e_commerce_app_flutter/farmer/widgets/CustomYellowButton.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import '../farmer/services/Helpers.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final bool userOnly;
  final String price;
  final bool isEnglish;
  final GestureTapCallback press;

  const ProductCard({
    required this.productId,
    required this.press,
    this.userOnly = false,
    this.isEnglish = true,
    required this.price,
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
    return FutureBuilder<Product>(
      future: ProductDatabaseHelper().getProductWithID(productId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Product product = snapshot.data!;
          print(product);
          return FutureBuilder<Position>(
            future: ProductDatabaseHelper().getProductLocation(productId),
            builder: (context, locationSnapshot) {
              if (locationSnapshot.hasData) {
                Position productLocation = locationSnapshot.data!;
                Position? userLocation = ProductDatabaseHelper()
                    .userLocation!; // Use the stored user location
                double distance = ProductDatabaseHelper()
                        .calculateDistance(userLocation, productLocation) /
                    1000; // Convert to km

                return GestureDetector(
                  onTap: press,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(26, 122, 224, 142),
                      border: Border.all(color: kTextColor.withOpacity(0.15)),
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12)),
                              child: CachedNetworkImage(
                                imageUrl: product.images?.isNotEmpty == true
                                    ? product.images![0]
                                    : 'https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg',
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${distance.toStringAsFixed(1)} km', // Display the distance
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                product.name ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (product.harvestDate != null)
                                _buildInfoRow(Icons.calendar_today,
                                    '${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),
                              // 'Hrvt Date: ${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${product.grade}\n",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        height: 0.5),
                                  ),
                                  Text(
                                    "${(product.rating!.toInt())}\n",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        height: 0.5),
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(
                                  product.price != null
                                      ? '₹ ${price} / Quintal'
                                      : 'Uncategorized',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: kPrimaryColor.withOpacity(0.1),
                              ),
                              // Chip(
                              //   label: Text(
                              //     product.price != null
                              //         ? '₹${product.price} / ${product.quantityName} '
                              //         : 'Uncategorized',
                              //     style: TextStyle(fontSize: 12),
                              //   ),
                              //   backgroundColor: kPrimaryColor.withOpacity(0.1),
                              // ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  product.isOrganic!
                                      ? Image.asset(
                                          "assets/icons/organic_icon.jpg",
                                          height: 20,
                                          width: 20,
                                        )
                                      : Container(),
                                  product.isDeliveryAvailable!
                                      ? SvgPicture.asset(
                                          "assets/icons/Cart Icon.svg",
                                          height: 20,
                                          width: 20,
                                        )
                                      : Container(),
                                  product.isPriceNegotiable!
                                      ? SvgPicture.asset(
                                          "assets/icons/Discount.svg",
                                          height: 20,
                                          width: 20,
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (locationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Center(child: Text('Location not available'));
              }
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text('Product not found'));
        }
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 12, color: kPrimaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
