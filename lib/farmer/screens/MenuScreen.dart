import 'package:e_commerce_app_flutter/farmer/routing/Application.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/UserInfo.dart' as UserInfo;
import '../widgets/MenuItem.dart';
import '../services/UserInfoProvider.dart';
import '../services/LocalizationProvider.dart';
import '../services/UserDatabaseService.dart';

class MenuScreen extends StatelessWidget {
  final UserDatabaseService userDatabaseService = UserDatabaseService();

  // Updated to use User instead of FirebaseUser (due to API updates)
  Widget userInfo(User? user) {
    if (user != null) {
      return FutureProvider.value(
        value: userDatabaseService.getUser(user.uid),
        initialData: null, // Initial data to avoid null issues
        child: UserInfo.UserInfo(),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // Using StreamProvider to get the current user
    final user = Provider.of<User?>(context);

    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;
    final language = Provider.of<LocalizationProvider>(context).currentLanguage;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          userInfo(user),
          menuItem(
            onPress: user == null
                ? () {
                    print("user is null");
                  }
                : () => Application.router
                    .navigateTo(context, '/my-products/${user.uid}'),
            title: isEnglish ? 'My Products' : 'मेरे उत्पाद',
            icon: Icons.storage,
          ),
          menuItem(
            onPress: user == null
                ? () {
                    print("user is null");
                  }
                : () => Application.router.navigateTo(context, '/add-product'),
            title: isEnglish ? 'Add Products' : 'मेरे उत्पाद',
            icon: Icons.storage,
          ),
          menuItem(
            onPress: () => Application.router.navigateTo(context, '/my-fields'),
            title: isEnglish ? 'Crop Calendar' : 'फसल कैलेंडर',
            icon: Icons.calendar_today,
          ),
          menuItem(
            onPress: () =>
                Application.router.navigateTo(context, '/chatbot/$language'),
            title: isEnglish ? 'Chatbot' : 'बॉट चैट करें',
            icon: Icons.chat_bubble_outline,
          ),
          menuItem(
            onPress: () => Application.router.navigateTo(context, '/weather'),
            title: isEnglish ? 'Weather Forecast' : 'मौसम पूर्वानुमान',
            icon: Icons.cloud,
          ),
          menuItem(
            onPress: () =>
                Application.router.navigateTo(context, '/settings/$language'),
            title: isEnglish ? 'Settings' : 'समायोजन',
            icon: Icons.settings,
          ),
          menuItem(
            onPress: () => UserInfoProvider.logOut(context),
            title: isEnglish ? 'Log out' : 'लॉग आउट',
            icon: Icons.exit_to_app,
          ),
        ],
      ),
    );
  }
}
