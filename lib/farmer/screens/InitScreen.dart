import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart' as Ujer;
import '../routing/Application.dart';
import '../services/LocalizationProvider.dart';
import '../services/UserDatabaseService.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  bool _redirect = false;
  String _redirectURL = '';

  Future<bool> _checkAuthStatus(BuildContext ctx) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final lang = sharedPreferences.getString('lang');

      if (lang == null) {
        _redirect = true;
        _redirectURL = "/set-language";
        return true;
      }

      final isEnglish = lang == 'en';
      await Provider.of<LocalizationProvider>(context, listen: false)
          .switchLanguage(isEnglish);

      final currentUser = await FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("1");
        _redirect = true;
        _redirectURL = "/login";
        return true;
      }
      print(currentUser);

      final databaseService = UserDatabaseService();
      Ujer.User? user = await databaseService.getUser(currentUser.uid);

      // // // final user = await databaseService.getUser(currentUser.uid);
      print(user);
      if (user == null) {
        print("2");
        _redirect = true;
        _redirectURL = "/userinfo";
        return true;
      }

      // print("object");
      _redirectURL = "/home";
      _redirect = true;
      return true;
    } catch (e) {
      print('Error checking auth status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
        ),
        width: double.infinity,
        child: Center(
          child: FutureBuilder<bool>(
            future: _checkAuthStatus(context),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                );
              }

              if (snapshot.hasData && snapshot.data == true) {
                Future.delayed(Duration(seconds: 2), () {
                  if (_redirect) {
                    print(_redirectURL);
                    Application.router.navigateTo(
                      context,
                      _redirectURL,
                      replace: true,
                    );
                  }
                });
                return Container(); // Loading complete, no need to show anything else
              }

              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Text(
                  "Authentication Error",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                );
              }

              return Container(); // Default case, return empty container
            },
          ),
        ),
      ),
    );
  }
}
