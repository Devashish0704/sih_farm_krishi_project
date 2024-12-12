// import 'dart:async';

// import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// import 'package:e_commerce_app_flutter/constants.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
// import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
// import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
// import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
// import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/toggle_datastreams.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:e_commerce_app_flutter/size_config.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import '../../../utils.dart';
// import '../components/home_header.dart';
// import 'product_type_box.dart';
// import 'products_section.dart';
// import 'product_categories.dart';
// import 'package:toggle_switch/toggle_switch.dart';
import 'dart:async';

import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/farmer/models/User.dart';
import 'package:e_commerce_app_flutter/farmer/screens/BidScreen.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
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
    final language = Provider.of<LocalizationProvider>(context).currentLanguage;

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
                    print(query);
                    if (query.length <= 0) return;
                    List<String> searchedProductsId;
                    try {
                      print("printed " + query);
                      searchedProductsId = await ProductDatabaseHelper()
                          .searchInProducts(query.toLowerCase());
                      print(searchedProductsId);
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
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildQuickActionButton(
                        icon: Icons.add_box,
                        label: isEnglish ? 'Add' : 'उत्पाद जोड़ें',
                        onTap: () {}
                        // onTap: () => Application.router
                        //     .navigateTo(context, '/add-product'),
                        ),
                    _buildQuickActionButton(
                        icon: Icons.storage,
                        label: isEnglish ? 'My Products' : 'मेरे उत्पाद',
                        onTap: () {}
                        // onTap: () => Application.router
                        //     .navigateTo(context, '/my-products/${user?.uid}'),
                        ),
                    _buildQuickActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: isEnglish ? 'Chatbot' : 'बॉट चैट करें',
                        onTap: () {}
                        // onTap: () => Application.router
                        //     .navigateTo(context, '/chatbot/$language'),
                        ),
                    _buildQuickActionButton(
                        icon: Icons.calendar_today,
                        label: isEnglish ? 'Crop Calendar' : 'फसल कैलेंडर',
                        onTap: () {}
                        // onTap: () =>
                        //     Application.router.navigateTo(context, '/my-fields'),
                        ),
                    _buildQuickActionButton(
                        icon: Icons.shopping_cart,
                        label: isEnglish ? 'Orders' : 'आर्डर',
                        onTap: () {}
                        // onTap: () =>
                        //     Application.router.navigateTo(context, '/orders'),
                        ),
                    _buildQuickActionButton(
                        icon: Icons.bakery_dining,
                        label: isEnglish ? 'BIDS' : 'आर्डर',
                        onTap: () async {
                          final currentUser =
                              await AuthentificationService().currentUser!.uid;

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BidScreen(
                                    userId: currentUser, urlType: "retailer"),
                              ));
                        }),
                    // _buildQuickActionButton(
                    //   icon: Icons.logout,
                    //   label: isEnglish ? 'Log Out' : 'लॉग आउट',
                    //   onTap: () => Provider.of<UserInfoProvider>(
                    //     context,
                    //     listen: false
                    //   ).logOut(context),
                    // ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(15)),

                // Updated to GridView
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Categories", style: headingStyle),
                    SizedBox(height: getProportionateScreenHeight(15)),
                    SizedBox(
                      height: SizeConfig.screenHeight *
                          0.4, // Adjusted height to accommodate grid
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 3 columns
                          childAspectRatio: 1, // Square cells
                          crossAxisSpacing: 5, // Spacing between columns
                          mainAxisSpacing: 10, // Spacing between rows
                        ),
                        // scrollDirection:
                        //     Axis.horizontal, // Allow horizontal scrolling
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
                                    category: productCategories[index]
                                        [PRODUCT_TYPE_KEY],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: getProportionateScreenHeight(20)),
                // SizedBox(height: getProportionateScreenHeight(80)),
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

// class Body extends StatefulWidget {
//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   final FavouriteProductsStream favouriteProductsStream =
//       FavouriteProductsStream();
//   final AllProductsStream allProductsStream = AllProductsStream();

//   // final BestSearchProductsStream bestSearchProductsStream =
//   //     BestSearchProductsStream();
//   // final NearbyProductsStream nearbyProductsStream = NearbyProductsStream();

//   bool isBestSearch = false; // Toggle state

//   @override
//   void initState() {
//     super.initState();

//     favouriteProductsStream.init();
//     allProductsStream.init();
//     // bestSearchProductsStream.init();
//     // nearbyProductsStream.init();

//     ProductDatabaseHelper().determinePosition();
//   }

//   @override
//   void dispose() {
//     favouriteProductsStream.dispose();
//     allProductsStream.dispose();
//     // bestSearchProductsStream.dispose();
//     // nearbyProductsStream.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: RefreshIndicator(
//         onRefresh: refreshPage,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: getProportionateScreenWidth(screenPadding)),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(height: getProportionateScreenHeight(15)),
//                 HomeHeader(
//                   onSearchSubmitted: (value) async {
//                     final query = value.toString();
//                     if (query.length <= 0) return;
//                     List<String> searchedProductsId;
//                     try {
//                       searchedProductsId = await ProductDatabaseHelper()
//                           .searchInProducts(query.toLowerCase());
//                       if (searchedProductsId != null) {
//                         await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SearchResultScreen(
//                               searchQuery: query,
//                               searchResultProductsId: searchedProductsId,
//                               searchIn: "All Products",
//                             ),
//                           ),
//                         );
//                         await refreshPage();
//                       } else {
//                         throw "Couldn't perform search due to some unknown reason";
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
//                 SizedBox(
//                   height: SizeConfig.screenHeight * 0.1,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       physics: BouncingScrollPhysics(),
//                       children: [
//                         ...List.generate(
//                           productCategories.length,
//                           (index) {
//                             return ProductTypeBox(
//                               icon: productCategories[index][ICON_KEY],
//                               title: productCategories[index][TITLE_KEY],
//                               onPress: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         CategoryProductsScreen(
//                                       category: productCategories[index]
//                                           [PRODUCT_TYPE_KEY],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: getProportionateScreenHeight(20)),

//                 // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
//                 // ToggleSwitch(
//                 //   initialLabelIndex: isBestSearch ? 1 : 0,
//                 //   totalSwitches: 2,
//                 //   labels: ['Nearby Products', 'Best Search '],
//                 //   activeBgColor: [Colors.green],
//                 //   inactiveBgColor: Colors.grey,
//                 //   activeFgColor: Colors.white,
//                 //   inactiveFgColor: Colors.black,
//                 //   minWidth: 180,
//                 //   onToggle: (index) {
//                 //     print('switched to: $index');
//                 //     setState(() {
//                 //       isBestSearch = (index == 1);
//                 //       if (isBestSearch) {
//                 //         bestSearchProductsStream.reload();
//                 //       } else {
//                 //         nearbyProductsStream.reload();
//                 //       }
//                 //     });
//                 //   },
//                 // ),

//                 SizedBox(height: getProportionateScreenHeight(20)),

//                 // SizedBox(
//                 //   height: SizeConfig.screenHeight * 0.8,
//                 //   child: ProductsSection(
//                 //     sectionTitle: isBestSearch
//                 //         ? "Best Rated Products"
//                 //         : "Nearby Products",
//                 //     productsStreamController: isBestSearch
//                 //         ? bestSearchProductsStream
//                 //         : nearbyProductsStream,
//                 //     emptyListMessage: isBestSearch
//                 //         ? "No highly rated products available"
//                 //         : "No nearby products available",
//                 //     onProductCardTapped: onProductCardTapped,
//                 //   ),
//                 // ),

//                 SizedBox(height: getProportionateScreenHeight(80)),
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

//   void onProductCardTapped(String productId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProductDetailsScreen(productId: productId),
//       ),
//     ).then((_) async {
//       await refreshPage();
//     });
//   }
// }
