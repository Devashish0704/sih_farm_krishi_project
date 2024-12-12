import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/cart/components/checkout_card.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/data_streams/cart_items_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/services/message.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final CartItemsStream cartItemsStream = CartItemsStream();
  PersistentBottomSheetController? bottomSheetHandler;
  Razorpay _razorpay = Razorpay();
  // BuildContext? razorpayContext;
  @override
  void initState() {
    super.initState();
    cartItemsStream.init();
    //    _paymentService = PaymentService();
    // _paymentService.initializeRazorpay(context);
    initializeRazorpay(context);
  }

  @override
  void dispose() {
    super.dispose();
    cartItemsStream.dispose();
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
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Your Cart",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: Center(
                      child: buildCartItemsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    cartItemsStream.reload();
    return Future<void>.value();
  }

  Widget buildCartItemsList() {
    return StreamBuilder<List<String>>(
      stream: cartItemsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> cartItemsId = snapshot.data!;
          if (cartItemsId.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_cart.svg",
                secondaryMessage: "Your cart is empty",
              ),
            );
          }

          return Column(
            children: [
              DefaultButton(
                text: "Proceed to Payment",
                press: () {
                  bottomSheetHandler = Scaffold.of(context).showBottomSheet(
                    (context) {
                      return CheckoutCard(
                        onCheckoutPressed: checkoutButtonCallback,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  physics: BouncingScrollPhysics(),
                  itemCount: cartItemsId.length,
                  itemBuilder: (context, index) {
                    if (index >= cartItemsId.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return buildCartItemDismissible(
                        context, cartItemsId[index], index);
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Widget buildCartItemDismissible(
      BuildContext context, String cartItemId, int index) {
    return Dismissible(
      key: Key(cartItemId),
      direction: DismissDirection.startToEnd,
      dismissThresholds: {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItemId, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Product from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              bool result = false;
              String snackbarMessage = "";
              try {
                result = await UserDatabaseHelper()
                    .removeProductFromCart(cartItemId);
                if (result == true) {
                  snackbarMessage = "Product removed from cart successfully";
                  await refreshPage();
                } else {
                  throw "Coulnd't remove product from cart due to unknown reason";
                }
              } on FirebaseException catch (e) {
                Logger().w("Firebase Exception: $e");
                snackbarMessage = "Something went wrong";
              } catch (e) {
                Logger().w("Unknown Exception: $e");
                snackbarMessage = "Something went wrong";
              } finally {
                Logger().i(snackbarMessage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackbarMessage),
                  ),
                );
              }

              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(String cartItemId, int index) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<Product>(
        future: ProductDatabaseHelper().getProductWithID(cartItemId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Product product = snapshot.data!;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
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
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kTextColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowUpCallback(cartItemId);
                          },
                        ),
                        SizedBox(height: 8),
                        FutureBuilder<CartItem>(
                          future: UserDatabaseHelper()
                              .getCartItemFromId(cartItemId),
                          builder: (context, snapshot) {
                            int itemCount = 0;
                            if (snapshot.hasData) {
                              final cartItem = snapshot.data!;
                              itemCount = cartItem.itemCount;
                            } else if (snapshot.hasError) {
                              final error = snapshot.error.toString();
                              Logger().e(error);
                            }
                            return Text(
                              "$itemCount",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowDownCallback(cartItemId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
            return Center(
              child: Text(
                error.toString(),
              ),
            );
          } else {
            return Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void initializeRazorpay(BuildContext context) {
    //  this.razorpayContext = context;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> checkoutButtonCallback() async {
    shutBottomSheet();

    final confirmation = await showConfirmationDialog(
      context,
      "Do you want to proceed with the order?",
    );

    if (confirmation == false) return;

    try {
      // Calculate total order amount
      final cartTotal = await UserDatabaseHelper().cartTotal;
      //   orderFuture.then((orderedProductsUid) async {
      // if (orderedProductsUid != null) {
      //   num totalAmount = 0;
      // for (var item in orderedProductsUid) {
      //   totalAmount += item['total'];
      // }

      // Convert to paisa (Razorpay accepts amount in paisa)
      int amountInPaisa = (cartTotal * 100).toInt();

      // Prepare Razorpay options
      var options = {
        //rzp_test_FOtq2H6xPAGziJ

        'key': 'rzp_test_FOtq2H6xPAGziJ', // Replace with your Razorpay Key ID
        'amount': amountInPaisa, // amount in paisa
        'name': 'Farm Krishi App',
        'description': 'Order Payment',
        'prefill': {
          'contact': '9667027786', // Optional
          'email': 'imranchopdar13@gmail.com' // Optional
        }
      };

      _razorpay.open(options);
      // }
      //  }
      // );
    } catch (e) {
      print('Error during checkout: $e');
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text('Payment process failed: $e')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(response);
    // Payment successful, proceed with order
    try {
      final orderFuture = UserDatabaseHelper().emptyCart();
      orderFuture.then((orderedProductsUid) async {
        if (orderedProductsUid != null) {
          final dateTime = DateTime.now();
          final formatedDateTime =
              "${dateTime.day}-${dateTime.month}-${dateTime.year}";

          List<OrderedProduct> orderedProducts = orderedProductsUid.map((e) {
            return OrderedProduct("",
                productUid: e["id"],
                quantity: e["count"],
                orderStatus: "Started",
                paymentStatus: "Paid",
                orderDate: formatedDateTime);
          }).toList();

          bool addedProductsToMyProducts =
              await UserDatabaseHelper().addToMyOrders(orderedProducts);

          if (addedProductsToMyProducts) {
            ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(content: Text('Payment Successful! Order Placed')),
            );
          }
        }
      });

      final number = Uri.encodeComponent('918949362882');
      final number2 = Uri.encodeComponent('919667027786');
      final message =
          Uri.encodeComponent('Congratulation for buying the product');
      final message2 = Uri.encodeComponent('Your product get sold');

      // Construct the full URL with properly encoded parameters
      final urla = Uri.parse(
          'https://localhost:4000/send?number=918949362882&message=Booked');
      final urlb = Uri.parse(
          'https://localhost:4000/send?number=$number2&message=$message');

      // try {
      // Add error handling and timeout
      final response = await http.get(urla).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Handle timeout scenario
          throw Exception('Request timed out');
        },
      );
      final responsew = await http.get(urlb).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Handle timeout scenario
          throw Exception('Request timed out');
        },
      );
      // bool successee = await MessageService().sendTextMessage(
      //   phoneNumber: "918949362882",
      //   message: "Your order has been placed successfully",
      // );

      // print(successee);

      final Uri url = Uri.parse('https://legal-form.onrender.com/');

      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error processing successful payment: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
          content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  // void dispose() {
  //   _razorpay.clear();
  // }

  // Future<void> checkoutButtonCallback() async {
  //   shutBottomSheet();
  //   final confirmation = await showConfirmationDialog(
  //     context,
  //     "Currently we are testing farm krishi app.\nDo you want to proceed for Mock Ordering of Products?",
  //   );
  //   if (confirmation == false) {
  //     return;
  //   }
  //   print("Proceeding for Mock Order");
  //   final orderFuture = UserDatabaseHelper().emptyCart();
  //   print(orderFuture);
  //   orderFuture.then((orderedProductsUid) async {
  //     if (orderedProductsUid != null) {
  //       print(orderedProductsUid);
  //       final dateTime = DateTime.now();
  //       final formatedDateTime =
  //           "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  //       List<OrderedProduct> orderedProducts = orderedProductsUid.map((e) {
  //         // print(e);
  //         return OrderedProduct("",
  //             productUid: e["id"],
  //             quantity: e["count"],
  //             orderStatus: "Ordered",
  //             orderDate: formatedDateTime);
  //       }).toList();
  //       print(orderedProducts);
  //       bool addedProductsToMyProducts = false;
  //       String snackbarmMessage = "";
  //       try {
  //         addedProductsToMyProducts =
  //             await UserDatabaseHelper().addToMyOrders(orderedProducts);
  //         if (addedProductsToMyProducts) {
  //           snackbarmMessage = "Products ordered Successfully";
  //         } else {
  //           throw "Could not order products due to unknown issue";
  //         }
  //       } on FirebaseException catch (e) {
  //         Logger().e(e.toString());
  //         snackbarmMessage = e.toString();
  //       } catch (e) {
  //         Logger().e(e.toString());
  //         snackbarmMessage = e.toString();
  //       } finally {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(snackbarmMessage ?? "Something went wrong"),
  //           ),
  //         );
  //       }
  //     } else {
  //       throw "Something went wrong while clearing cart";
  //     }
  //     await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AsyncProgressDialog(
  //           orderFuture,
  //           message: Text("Placing the Order"),
  //         );
  //       },
  //     );
  //   }).catchError((e) {
  //     Logger().e(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Something went wrong"),
  //       ),
  //     );
  //   });
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AsyncProgressDialog(
  //         orderFuture,
  //         message: Text("Placing the Order"),
  //       );
  //     },
  //   );
  //   await refreshPage();
  // }

  void shutBottomSheet() {
    if (bottomSheetHandler != null) {
      bottomSheetHandler!.close();
    }
  }

  Future<void> arrowUpCallback(String cartItemId) async {
    shutBottomSheet();
    final future = UserDatabaseHelper().increaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      Logger().e(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong"),
      ));
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AsyncProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }

  Future<void> arrowDownCallback(String cartItemId) async {
    shutBottomSheet();
    final future = UserDatabaseHelper().decreaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      Logger().e(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong"),
      ));
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AsyncProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }
}
