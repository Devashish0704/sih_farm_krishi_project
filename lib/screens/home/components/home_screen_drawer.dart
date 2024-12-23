import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/farmer/screens/InitScreen.dart';
import 'package:e_commerce_app_flutter/screens/about_developer/about_developer_screen.dart';
import 'package:e_commerce_app_flutter/screens/ai_hada_model/crop_name_to_grow.dart';
import 'package:e_commerce_app_flutter/screens/ai_hada_model/crop_production_screen.dart';
import 'package:e_commerce_app_flutter/screens/ai_hada_model/expected_price.dart';
import 'package:e_commerce_app_flutter/screens/ai_hada_model/n_p_k_value.dart';
import 'package:e_commerce_app_flutter/screens/change_display_picture/change_display_picture_screen.dart';
import 'package:e_commerce_app_flutter/screens/change_email/change_email_screen.dart';
import 'package:e_commerce_app_flutter/screens/change_password/change_password_screen.dart';
import 'package:e_commerce_app_flutter/screens/change_phone/change_phone_screen.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:e_commerce_app_flutter/screens/home/components/crop_calander.dart';
import 'package:e_commerce_app_flutter/screens/manage_addresses/manage_addresses_screen.dart';
import 'package:e_commerce_app_flutter/screens/my_orders/my_orders_screen.dart';
import 'package:e_commerce_app_flutter/screens/my_products/my_products_screen.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/home_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/services/dp-ratio/sort_for_price.dart';
import 'package:e_commerce_app_flutter/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../change_display_name/change_display_name_screen.dart';

class HomeScreenDrawer extends StatelessWidget {
  const HomeScreenDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          StreamBuilder<User?>(
              stream: AuthentificationService().userChanges,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return buildUserAccountsHeader(user);
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Center(
                    child: Icon(Icons.error),
                  );
                }
              }),
          buildEditAccountExpansionTile(context),
          ListTile(
            leading: Icon(Icons.edit_location),
            title: Text(
              "Manage Addresses",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () async {
              bool allowed = AuthentificationService().currentUserVerified;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageAddressesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.edit_location),
            title: Text(
              "My Orders",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () async {
              bool allowed = AuthentificationService().currentUserVerified;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOrdersScreen(),
                ),
              );
            },
          ),
          //  buildSellerExpansionTile(context),
          // ListTile(
          //   leading: Icon(Icons.info),
          //   title: Text(
          //     "About Developer",
          //     style: TextStyle(fontSize: 16, color: Colors.black),
          //   ),
          //   onTap: () async {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => AboutDeveloperScreen(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              "Sign out",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () async {
              final confirmation =
                  await showConfirmationDialog(context, "Confirm Sign out ?");
              if (confirmation) AuthentificationService().signOut();
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text(
              "Crop Calander",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropCalendarScreen(),
                )),
          ),
        ],
      ),
    );
  }

  UserAccountsDrawerHeader buildUserAccountsHeader(User user) {
    return UserAccountsDrawerHeader(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: kTextColor.withOpacity(0.15),
      ),
      accountEmail: Text(
        user.email ?? "No Email",
        style: TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
      accountName: Text(
        user.displayName ?? "No Name",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      currentAccountPicture: FutureBuilder(
        future: UserDatabaseHelper().displayPictureForCurrentUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data.toString()),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
          }
          return CircleAvatar(
            backgroundColor: kTextColor,
          );
        },
      ),
    );
  }

  ExpansionTile buildEditAccountExpansionTile(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.person),
      title: Text(
        "Edit Account",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      children: [
        ListTile(
          title: Text(
            "Change Display Picture",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeDisplayPictureScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Display Name",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeDisplayNameScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Phone Number",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePhoneScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Email",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Password",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Blink it",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Hada crop",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropProductionScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Hada which crop to grow ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropAdvisorScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Hada N P K value of crop",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NutrientAdvisorScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Hada expected price of crop",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropPriceAdvisorScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Hada expected price of crop",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () async {
            // List<Map<String, dynamic>> sortedData =
            //     await fetchCategoryData("vegetables");
            // print(sortedData);

            // double total = calculateTop10AveragePrice(sortedData);
            // print("total $total");

            // updateFixedPrice(cropName, total);

            // Map<String, Map<String, String>> productDetails =
            //     await getProductKeysForStates(sortedData, "Roma Tomato");
            // Map<String, Map<String, String>> productDetails =
            //     await getProductIdsAndPricesForCategory("vegetables");
            // print(productDetails);
          },
        ),
      ],
    );
  }

  Widget buildSellerExpansionTile(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.business),
      title: Text(
        "I am Farmer",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      children: [
        ListTile(
          title: Text(
            "GO to Farmers Dashboard",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () async {
            bool allowed = AuthentificationService().currentUserVerified;
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => InitScreen()));
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => EditProductScreen()));
          },
        ),
        // ListTile(
        //   title: Text(
        //     "Manage My Products",
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontSize: 15,
        //     ),
        //   ),
        //   onTap: () async {
        //     bool allowed = AuthentificationService().currentUserVerified;
        //     if (!allowed) {
        //       final reverify = await showConfirmationDialog(context,
        //           "You haven't verified your email address. This action is only allowed for verified users.",
        //           positiveResponse: "Resend verification email",
        //           negativeResponse: "Go back");
        //       if (reverify) {
        //         final future = AuthentificationService()
        //             .sendVerificationEmailToCurrentUser();
        //         await showDialog(
        //           context: context,
        //           builder: (context) {
        //             return AsyncProgressDialog(
        //               future,
        //               message: Text("Resending verification email"),
        //             );
        //           },
        //         );
        //       }
        //       return;
        //     }
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => MyProductsScreen(),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
