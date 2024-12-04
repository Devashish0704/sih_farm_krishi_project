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
          color: const Color.fromARGB(26, 122, 224, 142),
          border: Border.all(color: kTextColor.withOpacity(0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
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
    );
  }

  buildProductCardItems(Product product, BuildContext context) {
    // print(product);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              //  padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                imageUrl: product.images?.isNotEmpty == true
                    ? product.images![0]
                    : 'https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg',
                height: 74,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red),
              ),
            ),
            Positioned(
              top: 8, // Adjust this value for the vertical position
              right: 8, // Adjust this value for the horizontal position
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.6), // Background color with transparency
                  borderRadius:
                      BorderRadius.circular(8), // Rounded corners for the text
                ),
                child: Text(
                  '33km', // Replace with your desired text
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
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
                //   maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (product.harvestDate != null)
                _buildInfoRow(Icons.calendar_today,
                    'Hrvt Date: ${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${product.grade}\n",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 0.5),
                    //  maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${(product.rating!.toInt())}\n",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 0.5),
                    //  maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              Chip(
                label: Text(
                  product.price != null
                      ? '₹${product.price} / ${product.quantityName} '
                      : 'Uncategorized',
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: kPrimaryColor.withOpacity(0.1),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

              // Container(
              //   decoration: BoxDecoration(
              //     color: const Color.fromARGB(210, 2, 11, 131),
              //     border: Border.all(color: kTextColor.withOpacity(0.15)),
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(16),
              //     ),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Text(
              //       "\₹${product.price} / ${product.quantityName}\n",
              //       style: TextStyle(
              //           color: kPrimaryColor,
              //           fontWeight: FontWeight.w700,
              //           fontSize: 14,
              //           height: 0.5),
              //       //   maxLines: 2,
              //       //  overflow: TextOverflow.ellipsis,
              //     ),
              //   ),
              // ),

              //  SizedBox(height: 10),
              // TextButton(
              //     onPressed: () => Helpers.mapForDestination(
              //           product.position.latitude,
              //           product.position.longitude,
              //         ),
              //     child: Text("Go to Location")),
              // userOnly
              //     ? _editButtonsRow(context, product, isEnglish)
              //     : Container(),
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

  Widget _buildProductDetails(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.harvestDate != null)
          _buildInfoRow(Icons.calendar_today,
              'Harvest Date: ${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),
        if (product.storageMethod != null)
          _buildInfoRow(Icons.storage, 'Storage: ${product.storageMethod}'),
        _buildInfoRow(Icons.my_location,
            'Distance: ${_calculateDistance(product.position)} km'),
      ],
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

  String _formatProductType(ProductType type) {
    return type
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
        .capitalize();
  }

  double _calculateDistance(Position position) {
    // Implement distance calculation logic
    return 0.0; // Placeholder
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

Widget _buildInfoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: kPrimaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:e_commerce_app_flutter/farmer/routing/Application.dart';
// import 'package:e_commerce_app_flutter/farmer/screens/ProductsScreen/state/ProductsBloc.dart';
// import 'package:e_commerce_app_flutter/farmer/widgets/ConfirmationDialog.dart';
// import 'package:e_commerce_app_flutter/farmer/widgets/CustomYellowButton.dart';
// import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import '../constants.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import '../farmer/services/Helpers.dart';

// class ProductCard extends StatelessWidget {
//   final String productId;
//   final bool userOnly;
//   final bool isEnglish;
//   final GestureTapCallback press;
//   const ProductCard({
//     required this.productId,
//     required this.press,
//     this.userOnly = false,
//     this.isEnglish = true,
//   });

//   void _deleteProductConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => ConfirmationDialog(
//         () => Provider.of<ProductsBloc>(context, listen: false)
//             .deleteProduct(productId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: press,
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(26, 122, 224, 142),
//           border: Border.all(color: kTextColor.withOpacity(0.15)),
//           borderRadius: BorderRadius.all(
//             Radius.circular(16),
//           ),
//         ),
//         child: FutureBuilder<Product>(
//           future: ProductDatabaseHelper().getProductWithID(productId),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               final Product product = snapshot.data!;
//               return buildProductCardItems(product, context);
//             } else if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             } else if (snapshot.hasError) {
//               final error = snapshot.error.toString();
//               Logger().e(error);
//             }
//             return Center(
//               child: Icon(
//                 Icons.error,
//                 color: kTextColor,
//                 size: 60,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }


//   Column buildProductCardItems(Product product, BuildContext context) {

//   buildProductCardItems(Product product, BuildContext context) {

//     // print(product);
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Stack(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//               //  padding: const EdgeInsets.all(8.0),
//               child: CachedNetworkImage(
//                 imageUrl: product.images?.isNotEmpty == true
//                     ? product.images![0]
//                     : 'https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg',
//                 height: 80,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                     const Center(child: CircularProgressIndicator()),
//                 errorWidget: (context, url, error) =>
//                     Icon(Icons.error, color: Colors.red),
//               ),
//             ),
//             Positioned(
//               top: 8, // Adjust this value for the vertical position
//               right: 8, // Adjust this value for the horizontal position
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black
//                       .withOpacity(0.6), // Background color with transparency
//                   borderRadius:
//                       BorderRadius.circular(8), // Rounded corners for the text
//                 ),
//                 child: Text(
//                   '33km', // Replace with your desired text
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14, // Adjust font size as needed
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 5),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 product.name ?? 'Unnamed Product',
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 //   maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),

//               if (product.harvestDate != null)
//                 _buildInfoRow(Icons.calendar_today,
//                     'Hrvt Date: ${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "${product.grade}\n",
//                     style: TextStyle(
//                         color: kPrimaryColor,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                         height: 0.5),
//                     //  maxLines: 2,
//                     //     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     "${(product.rating!.toInt())}\n",
//                     style: TextStyle(
//                         color: kPrimaryColor,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                         height: 0.5),
//                     //  maxLines: 2,
//                     //     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),

//               Chip(
//                 label: Text(
//                   product.price != null
//                       ? '₹${product.price} / ${product.quantityName} '
//                       : 'Uncategorized',
//                   style: TextStyle(fontSize: 12),
//                 ),
//                 backgroundColor: kPrimaryColor.withOpacity(0.1),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   product.isOrganic!
//                       ? Image.asset(
//                           "assets/icons/organic_icon.jpg",
//                           height: 20,
//                           width: 20,
//                         )
//                       : Container(),
//                   product.isDeliveryAvailable!
//                       ? SvgPicture.asset(
//                           "assets/icons/Cart Icon.svg",
//                           height: 20,
//                           width: 20,
//                         )
//                       : Container(),
//                   product.isPriceNegotiable!
//                       ? SvgPicture.asset(
//                           "assets/icons/Discount.svg",
//                           height: 20,
//                           width: 20,
//                         )
//                       : Container(),
//                 ],
//               ),

//               // Container(
//               //   decoration: BoxDecoration(
//               //     color: const Color.fromARGB(210, 2, 11, 131),
//               //     border: Border.all(color: kTextColor.withOpacity(0.15)),
//               //     borderRadius: BorderRadius.all(
//               //       Radius.circular(16),
//               //     ),
//               //   ),
//               //   child: Padding(
//               //     padding: const EdgeInsets.all(8.0),
//               //     child: Text(
//               //       "\₹${product.price} / ${product.quantityName}\n",
//               //       style: TextStyle(
//               //           color: kPrimaryColor,
//               //           fontWeight: FontWeight.w700,
//               //           fontSize: 14,
//               //           height: 0.5),
//               //       //   maxLines: 2,
//               //       //  overflow: TextOverflow.ellipsis,
//               //     ),
//               //   ),
//               // ),

//               //  SizedBox(height: 10),
//               // TextButton(
//               //     onPressed: () => Helpers.mapForDestination(
//               //           product.position.latitude,
//               //           product.position.longitude,
//               //         ),
//               //     child: Text("Go to Location")),
//               // userOnly
//               //     ? _editButtonsRow(context, product, isEnglish)
//               //     : Container(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _viewButtonsRow(
//       BuildContext context, Product product, bool isEnglish) {
//     return Container(
//       color: Colors.transparent,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           CustomYellowButton(
//             text: isEnglish ? 'Call' : 'संपर्क',
//             icon: Icons.chat,
//             onPress: () {},
//           ),
//           CustomYellowButton(
//             text: isEnglish ? 'Location' : 'स्थान',
//             icon: Icons.my_location,
//             onPress: () => Helpers.mapForDestination(
//               product.position.latitude,
//               product.position.longitude,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _editButtonsRow(
//       BuildContext context, Product product, bool isEnglish) {
//     return Container(
//       color: Colors.transparent,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           CustomYellowButton(
//               text: isEnglish ? 'Edit' : 'संपादित करें',
//               icon: FontAwesomeIcons.edit,
//               onPress: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditProductScreen(
//                       productToEdit: product,
//                     ),
//                   ))),
//           CustomYellowButton(
//             text: isEnglish ? 'Delete' : 'मिटाओ',
//             icon: FontAwesomeIcons.trash,
//             onPress: () => _deleteProductConfirmation(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductDetails(Product product) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (product.harvestDate != null)
//           _buildInfoRow(Icons.calendar_today,
//               'Harvest Date: ${DateFormat('dd MMM yyyy').format(product.harvestDate!)}'),
//         if (product.storageMethod != null)
//           _buildInfoRow(Icons.storage, 'Storage: ${product.storageMethod}'),
//         _buildInfoRow(Icons.my_location,
//             'Distance: ${_calculateDistance(product.position)} km'),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 12, color: kPrimaryColor),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatProductType(ProductType type) {
//     return type
//         .toString()
//         .split('.')
//         .last
//         .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
//         .capitalize();
//   }

//   double _calculateDistance(Position position) {
//     // Implement distance calculation logic
//     return 0.0; // Placeholder
//   }
// }

// // Extension to capitalize first letter
// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }

// Widget _buildInfoRow(IconData icon, String text) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Row(
//       children: [
//         Icon(icon, size: 16, color: kPrimaryColor),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       ],
//     ),
//   );
// }
