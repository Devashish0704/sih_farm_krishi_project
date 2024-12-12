import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/farmer/models/User.dart';
import 'package:e_commerce_app_flutter/screens/webSceens/chatScreen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getOwnerIdFromProductId(String productId) async {
  try {
    // Get reference to the 'products' collection
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    // Get the document where the productId matches
    DocumentSnapshot productDoc = await productsCollection.doc(productId).get();

    // Check if the document exists
    if (productDoc.exists) {
      // Retrieve the ownerId from the document
      String ownerId = productDoc['owner'];

      return ownerId; // Return the ownerId
    } else {
      // Handle case where the document doesn't exist
      print('Product not found');
      return null;
    }
  } catch (e) {
    print('Error fetching product: $e');
    return null;
  }
}

class AddToCartFABRow extends StatelessWidget {
  const AddToCartFABRow({
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
    final user = Provider.of<User?>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Left FAB - Add to Cart
        FloatingActionButton.extended(
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
          icon: Icon(Icons.shopping_cart),
        ),

        // Right FAB - Dummy FAB
        FloatingActionButton(
          onPressed: () async {
            // print('Chat with buyer ${order.buyerId}');
            String? ownerId = await getOwnerIdFromProductId(productId);
            if (ownerId != null) {
              print('Owner ID: $ownerId');
            } else {
              print('Owner not found');
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        userId: user.toString(),
                        talkerId: ownerId!,
                        productId: productId)));
          },

          child: Icon(Icons.chat_bubble_outline),
          // backgroundColor: Colors.grey, // Optional - change to desired color
        ),
      ],
    );
  }
}
