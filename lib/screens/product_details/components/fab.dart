// import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
// import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils.dart';

class AddToCartFAB extends StatelessWidget {
  const AddToCartFAB({
    required this.productId,
  });

  final String productId;

  Future<int?> _showQuantityDialog(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? quantity = 1; // Default quantity
        return AlertDialog(
          title: Text('Select Quantity'),
          content: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter quantity',
            ),
            onChanged: (value) {
              quantity = int.tryParse(value);
            },
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            ElevatedButton(
              child: Text('Add to Cart'),
              onPressed: () {
                if (quantity != null && quantity! > 0) {
                  Navigator.of(context).pop(quantity);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        // Check user verification
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

        // Show quantity dialog
        final int? quantity = await _showQuantityDialog(context);

        // If user cancels or enters invalid quantity, do nothing
        if (quantity == null || quantity <= 0) return;

        // Proceed with adding to cart
        bool addedSuccessfully = false;
        String snackbarMessage = "";
        try {
          addedSuccessfully = await UserDatabaseHelper().addProductToCart(
            productId,
            quantity, // Assuming you'll modify the method to accept quantity
          );

          if (addedSuccessfully == true) {
            snackbarMessage = "Product added to cart successfully";
          } else {
            throw "Couldn't add product due to unknown reason";
          }
        } on FirebaseException catch (e) {
          print(e);
          snackbarMessage = "Something went wrong";
        } catch (e) {
          print(e);
          snackbarMessage = "Something went wrong";
        } finally {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarMessage),
            ),
          );
        }
      },
      label: Text(
        "Add to Cart",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      icon: Icon(
        Icons.shopping_cart,
      ),
    );
  }
}

// import '../../../utils.dart';

// class AddToCartFAB extends StatelessWidget {
//   const AddToCartFAB({
//     required this.productId,
//   });

//   final String productId;

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton.extended(
//       onPressed: () async {
//         bool allowed = AuthentificationService().currentUserVerified;
//         if (!allowed) {
//           final reverify = await showConfirmationDialog(context,
//               "You haven't verified your email address. This action is only allowed for verified users.",
//               positiveResponse: "Resend verification email",
//               negativeResponse: "Go back");
//           if (reverify) {
//             final future =
//                 AuthentificationService().sendVerificationEmailToCurrentUser();
//             await showDialog(
//               context: context,
//               builder: (context) {
//                 return AsyncProgressDialog(
//                   future,
//                   message: Text("Resending verification email"),
//                 );
//               },
//             );
//           }
//           return;
//         }
//         bool addedSuccessfully = false;
//         String snackbarMessage = "";
//         try {
//           addedSuccessfully =
//               await UserDatabaseHelper().addProductToCart(productId );
//           if (addedSuccessfully == true) {
//             snackbarMessage = "Product added successfully";
//           } else {
//             throw "Coulnd't add product due to unknown reason";
//           }
//         } on FirebaseException catch (e) {
//           print(e);
//           // Logger().w("Firebase Exception: $e");
//           snackbarMessage = "Something went wrong";
//         } catch (e) {
//           print(e);
//           // Logger().w("Unknown Exception: $e");
//           snackbarMessage = "Something went wrong";
//         } finally {
//           //  Logger().i(snackbarMessage);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(snackbarMessage),
//             ),
//           );
//         }
//       },
//       label: Text(
//         "Add to Cart",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//         ),
//       ),
//       icon: Icon(
//         Icons.shopping_cart,
//       ),
//     );
//   }
// }
