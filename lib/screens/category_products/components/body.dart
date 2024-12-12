// import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
// import 'package:e_commerce_app_flutter/components/product_card.dart';
// import 'package:e_commerce_app_flutter/components/rounded_icon_button.dart';
// import 'package:e_commerce_app_flutter/components/search_field.dart';
// import 'package:e_commerce_app_flutter/constants.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
// import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/category_products_stream.dart';
// import 'package:e_commerce_app_flutter/services/data_streams/toggle_datastreams.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:e_commerce_app_flutter/size_config.dart';
// import 'package:enum_to_string/enum_to_string.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:logger/logger.dart';
// import 'package:toggle_switch/toggle_switch.dart';

// class Body extends StatefulWidget {
//   final String category;

//   Body({required this.category});

//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   late BestSearchProductsStream bestSearchProductsStream;
//   late NearbyProductsStream nearbyProductsStream;

//   bool isBestSearch = false;

//   @override
//   void initState() {
//     super.initState();

//     bestSearchProductsStream =
//         BestSearchProductsStream(category: widget.category);
//     nearbyProductsStream = NearbyProductsStream(category: widget.category);

//     // Initialize both streams to avoid late initialization issues
//     bestSearchProductsStream.init();
//     nearbyProductsStream.init();
//   }

//   @override
//   void dispose() {
//     bestSearchProductsStream.dispose();
//     nearbyProductsStream.dispose();
//     super.dispose();
//   }

//   Future<void> refreshPage() {
//     if (isBestSearch) {
//       bestSearchProductsStream.reload();
//     } else {
//       nearbyProductsStream.reload();
//     }
//     return Future<void>.value();
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
//             child: SizedBox(
//               width: double.infinity,
//               child: Column(
//                 children: [
//                   SizedBox(height: getProportionateScreenHeight(20)),
//                   buildHeadBar(),
//                   SizedBox(height: getProportionateScreenHeight(20)),
//                   SizedBox(
//                     height: SizeConfig.screenHeight * 0.13,
//                     child: buildCategoryBanner(),
//                   ),
//                   SizedBox(
//                     height: SizeConfig.screenHeight * 0.01,
//                   ),
//                   // SizedBox(
//                   //   height: SizeConfig.screenHeight * 0.05,
//                   //   child: buildToggleSwitch(),
//                   // ),
//                   SizedBox(height: getProportionateScreenHeight(20)),
//                   SizedBox(
//                     height: SizeConfig.screenHeight * 0.68,
//                     child: StreamBuilder<List<String>>(
//                       stream: isBestSearch
//                           ? bestSearchProductsStream.stream
//                           : nearbyProductsStream.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData && snapshot.data != null) {
//                           List<String>? productsId = snapshot.data!;
//                           print("productsId $productsId");
//                           if (productsId.length == 0) {
//                             return Center(
//                               child: NothingToShowContainer(
//                                 secondaryMessage:
//                                     "No Products in ${widget.category}",
//                                 // "No Products in ${EnumToString.convertToString(widget.productType)}",
//                               ),
//                             );
//                           }

//                           return buildProductsGrid(productsId);
//                         } else if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         } else if (snapshot.hasError) {
//                           final error = snapshot.error;
//                           Logger().w(error.toString());
//                         }
//                         return Center(
//                           child: NothingToShowContainer(
//                             iconPath: "assets/icons/network_error.svg",
//                             primaryMessage: "Something went wrong",
//                             secondaryMessage: "Unable to connect to Database",
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: getProportionateScreenHeight(20)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildHeadBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         RoundedIconButton(
//           iconData: Icons.arrow_back_ios,
//           press: () {
//             Navigator.pop(context);
//           },
//         ),
//         SizedBox(width: 5),
//         Expanded(
//           child: SearchField(
//             onSubmit: (value) async {
//               final query = value.toString();
//               if (query.length <= 0) return;
//               // List<String> searchedProductsId;
//               Map<String, dynamic> searchedProductsIdandPrice;
//               try {
//                 // searchedProductsId = await ProductDatabaseHelper()
//                 //     .searchInProducts(query.toLowerCase());
//                 searchedProductsIdandPrice = await ProductDatabaseHelper()
//                     .fetchProductIdsAndPrice(cropName: query.toLowerCase());

//                 if (searchedProductsIdandPrice != null) {
//                   print(searchedProductsIdandPrice);
//                   double productPrice =
//                       searchedProductsIdandPrice["average_price"];
//                   int intproductPrice = productPrice.toInt();

//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SearchResultScreen(
//                         searchQuery: query,
//                         searchResultProductsId:
//                             searchedProductsIdandPrice["product_ids"],
//                         searchIn: "All Products",
//                         productPrice: intproductPrice.toString(),
//                       ),
//                     ),
//                   );
//                   await refreshPage();
//                 } else {
//                   throw "Couldn't perform search due to some unknown reason";
//                 }
//               } catch (e) {
//                 final error = e.toString();
//                 Logger().e(error);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("$error"),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildCategoryBanner() {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(bannerFromProductType()),
//               fit: BoxFit.fill,
//             ),
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Text(
//               widget.category,
//               // EnumToString.convertToString(widget.productType),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w900,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget buildToggleSwitch() {
//   //   return ToggleSwitch(
//   //     initialLabelIndex: isBestSearch ? 1 : 0,
//   //     totalSwitches: 2,
//   //     labels: ['Nearby Products', 'Best Search '],
//   //     activeBgColor: [Colors.green],
//   //     inactiveBgColor: Colors.grey,
//   //     activeFgColor: Colors.white,
//   //     inactiveFgColor: Colors.black,
//   //     minWidth: 180,
//   //     // minHeight: 0,
//   //     onToggle: (index) {
//   //       print('switched to: $index');
//   //       setState(() {
//   //         isBestSearch = (index == 1);
//   //         if (isBestSearch) {
//   //           bestSearchProductsStream.reload();
//   //         } else {
//   //           nearbyProductsStream.reload();
//   //         }
//   //       });
//   //     },
//   //   );
//   // }

//   Widget buildProductsGrid(List<String> productsId) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         vertical: 16,
//         horizontal: 8,
//       ),
//       decoration: BoxDecoration(
//         color: Color(0xFFF5F6F9),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: GridView.builder(
//         physics: BouncingScrollPhysics(),
//         itemCount: productsId.length,
//         shrinkWrap: true,
//         itemBuilder: (context, index) {
//           return ProductCard(
//             productId: productsId[index],
//             press: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ProductDetailsScreen(
//                     productId: productsId[index],
//                   ),
//                 ),
//               ).then(
//                 (_) async {
//                   await refreshPage();
//                 },
//               );
//             },
//             userOnly: false,
//             isEnglish: true,
//             price: '999',
//           );
//         },
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.75,
//           crossAxisSpacing: 2,
//           mainAxisSpacing: 8,
//         ),
//         padding: EdgeInsets.symmetric(
//           horizontal: 4,
//           vertical: 12,
//         ),
//       ),
//     );
//   }

//   String bannerFromProductType() {
//     switch (widget.category) {
//       case "Cereals":
//         return "assets/images/cereals_banner2.jpg";

//       case "Fish":
//         return "assets/images/fish_banner.webp";
//       case "Chicken":
//         return "assets/images/chicken_banner2.jpg";
//       case "Vegetables":
//         return "assets/images/vegitable_banner.webp";
//       case "Fruits":
//         return "assets/images/fruits_banner.webp";
//       case "Pulses":
//         return "assets/images/pulses_banner.webp";
//       case "Honey":
//         return "assets/images/honey_banner.jpg";
//       case "Milk":
//         return "assets/images/milk_banner.jpg";
//       case "Cheese":
//         return "assets/images/cheese_banner.jpg";
//       default:
//         return "assets/images/others_banner.jpg";
//     }
//   }
// }

import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_card.dart';
import 'package:e_commerce_app_flutter/components/rounded_icon_button.dart';
import 'package:e_commerce_app_flutter/components/search_field.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/data_streams/toggle_datastreams.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/dp-ratio/sort_for_price.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:e_commerce_app_flutter/services/data_streams/category_products_stream.dart';

class Body extends StatefulWidget {
  final String category;

  Body({required this.category});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late CropDetailsStream cropDetailsStream;

  @override
  void initState() {
    super.initState();
    cropDetailsStream = CropDetailsStream();
    cropDetailsStream.fetchCropDetails(widget.category);
  }

  @override
  void dispose() {
    cropDetailsStream.dispose();
    super.dispose();
  }

  Future<void> refreshPage() async {
    await cropDetailsStream.fetchCropDetails(widget.category);
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
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(20)),
                  buildHeadBar(),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.13,
                    child: buildCategoryBanner(),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.01,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  StreamBuilder<Map<String, dynamic>>(
                    stream: cropDetailsStream.cropDetailsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final cropDetails = snapshot.data!;
                        print(cropDetails);

                        // Convert map to a list of maps for products with price
                        final productsWithPrice = cropDetails.entries
                            .map((entry) => {
                                  'product_id': entry.value['productId'],
                                  'product_price': entry.value['price'],
                                })
                            .toList();

                        if (productsWithPrice.isEmpty) {
                          return Center(
                            child: NothingToShowContainer(
                              secondaryMessage:
                                  "No Products in ${widget.category}",
                            ),
                          );
                        }
                        return buildProductsGrid(productsWithPrice);
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        final error = snapshot.error;
                        Logger().w(error.toString());
                        return Center(
                          child: NothingToShowContainer(
                            iconPath: "assets/icons/network_error.svg",
                            primaryMessage: "Something went wrong",
                            secondaryMessage: "Unable to connect to Database",
                          ),
                        );
                      }
                      return Center(
                        child: NothingToShowContainer(
                          iconPath: "assets/icons/network_error.svg",
                          primaryMessage: "Something went wrong",
                          secondaryMessage: "Unable to connect to Database",
                        ),
                      );
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeadBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
          iconData: Icons.arrow_back_ios,
          press: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 5),
        Expanded(
          child: SearchField(
            onSubmit: (value) async {
              final query = value.toString();
              if (query.isEmpty) return;

              Map<String, dynamic> searchedProductsIdandPrice;
              try {
                // searchedProductsIdandPrice = await ProductDatabaseHelper()
                //     .fetchProductIdsAndPrice(cropName: query.toLowerCase());

                List<Map<String, dynamic>> sortedData =
                    await fetchAndSortCropData(query.toLowerCase());

                double total = calculateTop10AveragePrice(sortedData);

                updateFixedPrice(query.toLowerCase(), total);

                Map<String, Map<String, String>> productDetails =
                    await getProductKeysForStatesAndUpdatePrices(
                        sortedData, query.toLowerCase(), total);

                searchedProductsIdandPrice = await ProductDatabaseHelper()
                    .fetchProductIdsAndPrice(cropName: query.toLowerCase());

                if (searchedProductsIdandPrice != null) {
                  double productPrice =
                      searchedProductsIdandPrice["average_price"];
                  int intProductPrice = productPrice.toInt();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultScreen(
                        searchQuery: query,
                        searchResultProductsId:
                            searchedProductsIdandPrice["product_ids"],
                        searchIn: "All Products",
                        productPrice: intProductPrice.toString(),
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
                  SnackBar(content: Text("$error")),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryBanner() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bannerFromProductType()),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.category,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductsGrid(List<Map<String, dynamic>> productsWithPrice) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: productsWithPrice.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final product = productsWithPrice[index];
          final productId = product['product_id'];
          final productPrice = product['product_price'];

          print("yo");
          print(productId);
          print(productPrice);

          return ProductCard(
            productId: productId,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    productId: productId,
                  ),
                ),
              ).then((_) async {
                await refreshPage();
              });
            },
            userOnly: false,
            isEnglish: true,
            price: productPrice.toString(),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 2,
          mainAxisSpacing: 8,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
    );
  }

  String bannerFromProductType() {
    switch (widget.category) {
      case "Cereals":
        return "assets/images/cereals_banner2.jpg";
      case "Fish":
        return "assets/images/fish_banner.webp";
      case "Chicken":
        return "assets/images/chicken_banner2.jpg";
      case "Vegetables":
        return "assets/images/vegitable_banner.webp";
      case "Fruits":
        return "assets/images/fruits_banner.webp";
      case "Pulses":
        return "assets/images/pulses_banner.webp";
      case "Honey":
        return "assets/images/honey_banner.jpg";
      case "Milk":
        return "assets/images/milk_banner.jpg";
      case "Cheese":
        return "assets/images/cheese_banner.jpg";
      default:
        return "assets/images/others_banner.jpg";
    }
  }
}
