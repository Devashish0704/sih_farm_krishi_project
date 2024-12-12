import 'dart:async';

import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/farmer/screens/BidScreen.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/screens/webSceens/chatBot.dart';
import 'package:e_commerce_app_flutter/screens/webSceens/chatHistoryScreen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';
import '../components/home_header.dart';
import 'product_type_box.dart';
import 'product_categories.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final FavouriteProductsStream favouriteProductsStream =
      FavouriteProductsStream();
  final AllProductsStream allProductsStream = AllProductsStream();

  @override
  void initState() {
    super.initState();
    favouriteProductsStream.init();
    allProductsStream.init();
    ProductDatabaseHelper().determinePosition();
  }

  @override
  void dispose() {
    favouriteProductsStream.dispose();
    allProductsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),

                // Home Header with Search
                HomeHeader(
                  onSearchSubmitted: _handleSearchSubmission,
                  onCartButtonPressed: _handleCartNavigation,
                ),

                SizedBox(height: getProportionateScreenHeight(15)),

                // Quick Action Buttons
                _buildQuickActionsSection(context, user, isEnglish),

                SizedBox(height: getProportionateScreenHeight(15)),

                // Featured Offers Banner
                _buildFeaturedOffersBanner(context),

                SizedBox(height: getProportionateScreenHeight(15)),

                // Categories Section
                _buildCategoriesSection(context, isEnglish),

                SizedBox(height: getProportionateScreenHeight(15)),

                // Trending Products Section
                _buildTrendingProductsSection(context),

                SizedBox(height: getProportionateScreenHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActionsSection(
      BuildContext context, User? user, bool isEnglish) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 20,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildQuickActionButton(
          icon: Icons.chat,
          label: isEnglish ? 'Chat' : 'चैट',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatHistoryScreen(userId: user!.uid),
            ),
          ),
        ),
        _buildQuickActionButton(
          icon: Icons.chat_bubble_outline,
          label: isEnglish ? 'Chatbot' : 'बॉट चैट',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatbotScreen(userId: user!.uid),
            ),
          ),
        ),
        _buildQuickActionButton(
          icon: Icons.bakery_dining,
          label: isEnglish ? 'Bids' : 'बोली',
          onTap: () async {
            final currentUser =
                await AuthentificationService().currentUser!.uid;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BidScreen(userId: currentUser, urlType: "retailer"),
              ),
            );
          },
        ),
      ],
    );
  }

  // Featured Offers Banner
  Widget _buildFeaturedOffersBanner(BuildContext context) {
    return Container(
      height: getProportionateScreenHeight(160),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Seasonal Offers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Get up to 30% off on fresh produce this season!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to offers page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Shop Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Categories Section
  Widget _buildCategoriesSection(BuildContext context, bool isEnglish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isEnglish ? "Product Categories" : "उत्पाद श्रेणियाँ",
            style: headingStyle),
        SizedBox(height: getProportionateScreenHeight(15)),
        SizedBox(
          height: SizeConfig.screenHeight * 0.4,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10,
            ),
            physics: BouncingScrollPhysics(),
            itemCount: productCategories.length,
            itemBuilder: (context, index) {
              return ProductTypeBox(
                icon: productCategories[index][ICON_KEY],
                title: productCategories[index][TITLE_KEY],
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        category: productCategories[index][PRODUCT_TYPE_KEY],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Trending Products Section
  Widget _buildTrendingProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trending Products', style: headingStyle),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(right: 10),
                child: _buildTrendingProductCard(),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingProductCard() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=600',
              height: 120,
              width: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh Tomatoes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹50/kg',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.add_shopping_cart, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search Submission Handler
  Future<void> _handleSearchSubmission(String value) async {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return;

    // try {
    //   // final Map<String, dynamic> searchedProductsIdandPrice =
    //   //     await ProductDatabaseHelper().fetchProductIdsAndPrice(
    //   //   cropName: query.toLowerCase(),
    //   // );

    //     if (searchedProductsIdandPrice != null) {
    //       List<dynamic> products = searchedProductsIdandPrice['products'];
    //       List<String> productIds =
    //           products.map((product) => product['product_id'] as String).toList();

    //       double productPrice = searchedProductsIdandPrice["average_price"];
    //       int intProductPrice = productPrice.toInt();

    //       await Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => SearchResultScreen(
    //             searchQuery: query,
    //             searchResultProductsId: productIds,
    //             searchIn: "All Products",
    //             productPrice: intProductPrice.toString(),
    //           ),
    //         ),
    //       );
    //       await refreshPage();
    //     }
    //   } catch (e) {
    //     final error = e.toString();
    //     Logger().e(error);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text("$error"),
    //       ),
    //     );
    //   }
  }

  // Cart Navigation Handler
  Future<void> _handleCartNavigation() async {
    bool allowed = AuthentificationService().currentUserVerified;
    if (!allowed) {
      final reverify = await showConfirmationDialog(
        context,
        "You haven't verified your email address. This action is only allowed for verified users.",
        positiveResponse: "Resend verification email",
        negativeResponse: "Go back",
      );
      if (reverify) {
        final future =
            AuthentificationService().sendVerificationEmailToCurrentUser();
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
  }

  Future<void> refreshPage() {
    favouriteProductsStream.reload();
    allProductsStream.reload();
    return Future<void>.value();
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 251, 248),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 103, 14, 63).withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.green),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// import 'package:e_commerce_app_flutter/constants.dart';
// import 'package:e_commerce_app_flutter/farmer/screens/BidScreen.dart';
// import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
// import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
// import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
// import 'package:e_commerce_app_flutter/screens/home/components/crop_calander.dart';
// import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
// import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
// import 'package:e_commerce_app_flutter/screens/webSceens/chatBot.dart';
// import 'package:e_commerce_app_flutter/screens/webSceens/chatHistoryScreen.dart';
// import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:e_commerce_app_flutter/services/dp-ratio/sort_for_price.dart';
// import 'package:e_commerce_app_flutter/size_config.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';

// import '../../../utils.dart';
// import '../components/home_header.dart';
// import 'product_type_box.dart';
// import 'product_categories.dart';

// class Body extends StatefulWidget {
//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   final FavouriteProductsStream favouriteProductsStream =
//       FavouriteProductsStream();
//   final AllProductsStream allProductsStream = AllProductsStream();

//   @override
//   void initState() {
//     super.initState();
//     favouriteProductsStream.init();
//     allProductsStream.init();
//     ProductDatabaseHelper().determinePosition();
//   }

//   @override
//   void dispose() {
//     favouriteProductsStream.dispose();
//     allProductsStream.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User?>(context);
//     final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

//     return SafeArea(
//       child: RefreshIndicator(
//         onRefresh: refreshPage,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: getProportionateScreenWidth(screenPadding),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Home Header with Search
//                 HomeHeader(
//                   onSearchSubmitted: _handleSearchSubmission,
//                   onCartButtonPressed: _handleCartNavigation,
//                 ),

//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Quick Action Buttons
//                 _buildQuickActionsSection(context, user, isEnglish),

//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Featured Offers Banner
//                 _buildFeaturedOffersBanner(context),

//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Categories Section
//                 _buildCategoriesSection(context, isEnglish),

//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Trending Products Section
//                 _buildTrendingProductsSection(context),

//                 SizedBox(height: getProportionateScreenHeight(20)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Quick Actions Section
//   Widget _buildQuickActionsSection(
//       BuildContext context, User? user, bool isEnglish) {
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 3,
//       crossAxisSpacing: 15,
//       mainAxisSpacing: 20,
//       physics: NeverScrollableScrollPhysics(),
//       children: [
//         _buildQuickActionButton(
//           icon: Icons.chat,
//           label: isEnglish ? 'Chat' : 'चैट',
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatHistoryScreen(userId: user!.uid),
//             ),
//           ),
//         ),
//         _buildQuickActionButton(
//           icon: Icons.chat_bubble_outline,
//           label: isEnglish ? 'Chatbot' : 'बॉट चैट',
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatbotScreen(userId: user!.uid),
//             ),
//           ),
//         ),
//         _buildQuickActionButton(
//           icon: Icons.bakery_dining,
//           label: isEnglish ? 'Bids' : 'बोली',
//           onTap: () async {
//             final currentUser =
//                 await AuthentificationService().currentUser!.uid;
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     BidScreen(userId: currentUser, urlType: "retailer"),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // Featured Offers Banner
//   Widget _buildFeaturedOffersBanner(BuildContext context) {
//     return Container(
//       height: getProportionateScreenHeight(160),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF6A11CB),
//             Color(0xFF2575FC),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             offset: Offset(0, 4),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Seasonal Offers',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Get up to 30% off on fresh produce this season!',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 15),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Navigate to offers page
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Text('Shop Now'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Categories Section
//   Widget _buildCategoriesSection(BuildContext context, bool isEnglish) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(isEnglish ? "Product Categories" : "उत्पाद श्रेणियाँ",
//             style: headingStyle),
//         SizedBox(height: getProportionateScreenHeight(15)),
//         SizedBox(
//           height: SizeConfig.screenHeight * 0.4,
//           child: GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               childAspectRatio: 1,
//               crossAxisSpacing: 5,
//               mainAxisSpacing: 10,
//             ),
//             physics: BouncingScrollPhysics(),
//             itemCount: productCategories.length,
//             itemBuilder: (context, index) {
//               return ProductTypeBox(
//                 icon: productCategories[index][ICON_KEY],
//                 title: productCategories[index][TITLE_KEY],
//                 onPress: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CategoryProductsScreen(
//                         category: productCategories[index][PRODUCT_TYPE_KEY],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // Trending Products Section
//   Widget _buildTrendingProductsSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Trending Products', style: headingStyle),
//         SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(3, (index) {
//               return Padding(
//                 padding: EdgeInsets.only(right: 10),
//                 child: _buildTrendingProductCard(),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTrendingProductCard() {
//     return Container(
//       width: 180,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//             child: Image.network(
//               'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=600',
//               height: 120,
//               width: 180,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Fresh Tomatoes',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '₹50/kg',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Icon(Icons.add_shopping_cart, color: Colors.green),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Search Submission Handler
//   Future<void> _handleSearchSubmission(String value) async {
//     final query = value.trim().toLowerCase();
//     if (query.isEmpty) return;

//                     try {
//                       // Call fetchProductIdsAndPrice with cropName
//                       final Map<String, dynamic> searchedProductsIdandPrice =
//                           await ProductDatabaseHelper().fetchProductIdsAndPrice(
//                               cropName: query.toLowerCase());

//                       if (searchedProductsIdandPrice != null) {
//                         print(searchedProductsIdandPrice);

//                         // Extract product IDs from the result
//                         List<dynamic> products =
//                             searchedProductsIdandPrice['products'];
//                         List<String> productIds = products
//                             .map((product) => product['product_id'] as String)
//                             .toList();

//                         // Optionally, you can also extract the average price if needed
//                         double productPrice =
//                             searchedProductsIdandPrice["average_price"];
//                         int intProductPrice = productPrice.toInt();

// >>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409
//                         await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SearchResultScreen(
//                               searchQuery: query,
//                               searchResultProductsId:
//                                   productIds, // Only product IDs
//                               searchIn: "All Products",
//                               productPrice:
//                                   intProductPrice.toString(), // Average price
//                             ),
//                           ),
//                         );
//                         await refreshPage();
//                       }
//                     } catch (e) {
//                       final error = e.toString();
//                       Logger().e(error);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("$error"),
//                         ),
//                       );
//                     }
//                   },
//                   onCartButtonPressed: () async {
//                     bool allowed =
//                         AuthentificationService().currentUserVerified;
//                     if (!allowed) {
//                       final reverify = await showConfirmationDialog(context,
//                           "You haven't verified your email address. This action is only allowed for verified users.",
//                           positiveResponse: "Resend verification email",
//                           negativeResponse: "Go back");
//                       if (reverify) {
//                         final future = AuthentificationService()
//                             .sendVerificationEmailToCurrentUser();
//                         await showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AsyncProgressDialog(
//                               future,
//                               message: Text("Resending verification email"),
//                             );
//                           },
//                         );
//                       }
//                       return;
//                     }
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CartScreen(),
//                       ),
//                     );
//                     await refreshPage();
//                   },
//                 ),
//                 SizedBox(height: getProportionateScreenHeight(15)),
//                 GridView.count(
//                   shrinkWrap: true,
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 20,
//                   physics: NeverScrollableScrollPhysics(),
//                   children: [
//                     _buildQuickActionButton(
//                         icon: Icons.add_box,
//                         label: isEnglish ? 'Add' : 'उत्पाद जोड़ें',
//                         onTap: () {}
//                         // onTap: () => Application.router
//                         //     .navigateTo(context, '/add-product'),
//                         ),
//                     _buildQuickActionButton(
//                         icon: Icons.storage,
//                         label: isEnglish ? 'My Products' : 'मेरे उत्पाद',
//                         onTap: () {}
//                         // onTap: () => Application.router
//                         //     .navigateTo(context, '/my-products/${user?.uid}'),
//                         ),
//                     _buildQuickActionButton(
//                         icon: Icons.chat_bubble_outline,
//                         label: isEnglish ? 'Chatbot' : 'बॉट चैट करें',
//                         onTap: () {}
//                         // onTap: () => Application.router
//                         //     .navigateTo(context, '/chatbot/$language'),
//                         ),
//                     _buildQuickActionButton(
//                         icon: Icons.calendar_today,
//                         label: isEnglish ? 'Crop Calendar' : 'फसल कैलेंडर',
//                         onTap: () {}
//                         // onTap: () =>
//                         //     Application.router.navigateTo(context, '/my-fields'),
//                         ),
//                     _buildQuickActionButton(
//                         icon: Icons.shopping_cart,
//                         label: isEnglish ? 'Orders' : 'आर्डर',
//                         onTap: () {}
//                         // onTap: () =>
//                         //     Application.router.navigateTo(context, '/orders'),
//                         ),
//                     _buildQuickActionButton(
//                         icon: Icons.bakery_dining,
//                         label: isEnglish ? 'BIDS' : 'आर्डर',
//                         onTap: () async {
//                           final currentUser =
//                               await AuthentificationService().currentUser!.uid;

//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => BidScreen(
//                                     userId: currentUser, urlType: "retailer"),
//                               ));
//                         }),
//                     // _buildQuickActionButton(
//                     //   icon: Icons.logout,
//                     //   label: isEnglish ? 'Log Out' : 'लॉग आउट',
//                     //   onTap: () => Provider.of<UserInfoProvider>(
//                     //     context,
//                     //     listen: false
//                     //   ).logOut(context),
//                     // ),
//                   ],
//                 ),
//                 SizedBox(height: getProportionateScreenHeight(15)),

//                 // Updated to GridView
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Categories", style: headingStyle),
//                     SizedBox(height: getProportionateScreenHeight(15)),
//                     SizedBox(
//                       height: SizeConfig.screenHeight *
//                           0.4, // Adjusted height to accommodate grid
//                       child: GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 4, // 3 columns
//                           childAspectRatio: 1, // Square cells
//                           crossAxisSpacing: 5, // Spacing between columns
//                           mainAxisSpacing: 10, // Spacing between rows
//                         ),
//                         // scrollDirection:
//                         //     Axis.horizontal, // Allow horizontal scrolling
//                         physics: BouncingScrollPhysics(),
//                         itemCount: productCategories.length,
//                         itemBuilder: (context, index) {
//                           return ProductTypeBox(
//                             icon: productCategories[index][ICON_KEY],
//                             title: productCategories[index][TITLE_KEY],
//                             onPress: () {
//                               // print();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CategoryProductsScreen(
//                                     category: productCategories[index]
//                                         [PRODUCT_TYPE_KEY],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: getProportionateScreenHeight(20)),
//                 // SizedBox(height: getProportionateScreenHeight(80)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> refreshPage() {
//     favouriteProductsStream.reload();
//     allProductsStream.reload();
//     return Future<void>.value();
//   }

//   Widget _buildQuickActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 243, 251, 248),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 103, 14, 63).withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 5,
//             ),
//           ],
//         ),
//         padding: EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 35, color: Colors.green),
//             SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// // import 'package:e_commerce_app_flutter/constants.dart';

// // import 'package:e_commerce_app_flutter/farmer/screens/BidScreen.dart';
// // import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
// // import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
// // import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
// // import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
// // import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
// // import 'package:e_commerce_app_flutter/screens/webSceens/chatBot.dart';
// // import 'package:e_commerce_app_flutter/screens/webSceens/chatHistoryScreen.dart';
// // import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
// // import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
// // import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
// // import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// // import 'package:e_commerce_app_flutter/size_config.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:logger/logger.dart';
// // import 'package:provider/provider.dart';
// // import '../../../utils.dart';
// // import '../components/home_header.dart';
// // import 'product_type_box.dart';
// // import 'product_categories.dart';

// // class Body extends StatefulWidget {
// //   @override
// //   _BodyState createState() => _BodyState();
// // }

// // class _BodyState extends State<Body> {
// //   final FavouriteProductsStream favouriteProductsStream =
// //       FavouriteProductsStream();
// //   final AllProductsStream allProductsStream = AllProductsStream();

// //   @override
// //   void initState() {
// //     super.initState();

// //     favouriteProductsStream.init();
// //     allProductsStream.init();

// //     ProductDatabaseHelper().determinePosition();
// //   }

// //   @override
// //   void dispose() {
// //     favouriteProductsStream.dispose();
// //     allProductsStream.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final user = Provider.of<User?>(context);

// //     final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;
// //     final language = Provider.of<LocalizationProvider>(context).currentLanguage;

// //     return SafeArea(
// //       child: RefreshIndicator(
// //         onRefresh: refreshPage,
// //         child: SingleChildScrollView(
// //           physics: AlwaysScrollableScrollPhysics(),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(
// //                 horizontal: getProportionateScreenWidth(screenPadding)),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.max,
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 SizedBox(height: getProportionateScreenHeight(15)),
// //                 HomeHeader(
// //                   onSearchSubmitted: (value) async {
// //                     final query = value.trim().toLowerCase();
// //                     if (query.isEmpty) return;

// //                     try {
// //                       // Call fetchProductIdsAndPrice with cropName
// //                       final Map<String, dynamic> searchedProductsIdandPrice =
// //                           await ProductDatabaseHelper().fetchProductIdsAndPrice(
// //                               cropName: query.toLowerCase());

// //                       if (searchedProductsIdandPrice != null) {
// //                         print(searchedProductsIdandPrice);

// //                         // Extract product IDs from the result
// //                         List<dynamic> products =
// //                             searchedProductsIdandPrice['products'];
// //                         List<String> productIds = products
// //                             .map((product) => product['product_id'] as String)
// //                             .toList();

// //                         // Optionally, you can also extract the average price if needed
// //                         double productPrice =
// //                             searchedProductsIdandPrice["average_price"];
// //                         int intProductPrice = productPrice.toInt();

// //                         await Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => SearchResultScreen(
// //                               searchQuery: query,
// //                               searchResultProductsId:
// //                                   productIds, // Only product IDs
// //                               searchIn: "All Products",
// //                               productPrice:
// //                                   intProductPrice.toString(), // Average price
// //                             ),
// //                           ),
// //                         );
// //                         await refreshPage();
// //                       }
// //                     } catch (e) {
// //                       final error = e.toString();
// //                       Logger().e(error);
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         SnackBar(
// //                           content: Text("$error"),
// //                         ),
// //                       );
// //                     }
// //                   },
// //                   onCartButtonPressed: () async {
// //                     bool allowed =
// //                         AuthentificationService().currentUserVerified;
// //                     if (!allowed) {
// //                       final reverify = await showConfirmationDialog(context,
// //                           "You haven't verified your email address. This action is only allowed for verified users.",
// //                           positiveResponse: "Resend verification email",
// //                           negativeResponse: "Go back");
// //                       if (reverify) {
// //                         final future = AuthentificationService()
// //                             .sendVerificationEmailToCurrentUser();
// //                         await showDialog(
// //                           context: context,
// //                           builder: (context) {
// //                             return AsyncProgressDialog(
// //                               future,
// //                               message: Text("Resending verification email"),
// //                             );
// //                           },
// //                         );
// //                       }
// //                       return;
// //                     }
// //                     await Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => CartScreen(),
// //                       ),
// //                     );
// //                     await refreshPage();
// //                   },
// //                 ),
// //                 SizedBox(height: getProportionateScreenHeight(15)),
// //                 GridView.count(
// //                   shrinkWrap: true,
// //                   crossAxisCount: 3,
// //                   crossAxisSpacing: 15,
// //                   mainAxisSpacing: 20,
// //                   physics: NeverScrollableScrollPhysics(),
// //                   children: [
// //                     _buildQuickActionButton(
// //                       icon: Icons.chat,
// //                       label: isEnglish ? 'Chat' : 'chat',
// //                       onTap: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) =>
// //                                 ChatHistoryScreen(userId: user!.uid),
// //                           )),
// //                     ),
// //                     _buildQuickActionButton(
// //                       icon: Icons.chat_bubble_outline,
// //                       label: isEnglish ? 'Chatbot' : 'बॉट चैट करें',
// //                       onTap: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) =>
// //                                 ChatbotScreen(userId: user!.uid),
// //                           )),
// //                     ),

// //                     _buildQuickActionButton(
// //                         icon: Icons.bakery_dining,
// //                         label: isEnglish ? 'BIDS' : 'आर्डर',
// //                         onTap: () async {
// //                           final currentUser =
// //                               await AuthentificationService().currentUser!.uid;

// //                           Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => BidScreen(
// //                                     userId: currentUser, urlType: "retailer"),
// //                               ));
// //                         }),
// //                     // _buildQuickActionButton(
// //                     //   icon: Icons.logout,
// //                     //   label: isEnglish ? 'Log Out' : 'लॉग आउट',
// //                     //   onTap: () => Provider.of<UserInfoProvider>(
// //                     //     context,
// //                     //     listen: false
// //                     //   ).logOut(context),
// //                     // ),
// //                   ],
// //                 ),
// //                 SizedBox(height: getProportionateScreenHeight(15)),

// //                 // Updated to GridView
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text("Categories", style: headingStyle),
// //                     SizedBox(height: getProportionateScreenHeight(15)),
// //                     SizedBox(
// //                       height: SizeConfig.screenHeight *
// //                           0.4, // Adjusted height to accommodate grid
// //                       child: GridView.builder(
// //                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                           crossAxisCount: 4, // 3 columns
// //                           childAspectRatio: 1, // Square cells
// //                           crossAxisSpacing: 5, // Spacing between columns
// //                           mainAxisSpacing: 10, // Spacing between rows
// //                         ),
// //                         // scrollDirection:
// //                         //     Axis.horizontal, // Allow horizontal scrolling
// //                         physics: BouncingScrollPhysics(),
// //                         itemCount: productCategories.length,
// //                         itemBuilder: (context, index) {
// //                           return ProductTypeBox(
// //                             icon: productCategories[index][ICON_KEY],
// //                             title: productCategories[index][TITLE_KEY],
// //                             onPress: () {
// //                               // print();
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (context) => CategoryProductsScreen(
// //                                     category: productCategories[index]
// //                                         [PRODUCT_TYPE_KEY],
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 SizedBox(height: getProportionateScreenHeight(20)),
// //                 // SizedBox(height: getProportionateScreenHeight(80)),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> refreshPage() {
// //     favouriteProductsStream.reload();
// //     allProductsStream.reload();
// //     return Future<void>.value();
// //   }

// //   Widget _buildQuickActionButton({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //   }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color.fromARGB(255, 243, 251, 248),
// //           borderRadius: BorderRadius.circular(10),
// //           boxShadow: [
// //             BoxShadow(
// //               color: const Color.fromARGB(255, 103, 14, 63).withOpacity(0.2),
// //               spreadRadius: 1,
// //               blurRadius: 5,
// //             ),
// //           ],
// //         ),
// //         padding: EdgeInsets.all(12),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, size: 35, color: Colors.green),
// //             SizedBox(height: 8),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
