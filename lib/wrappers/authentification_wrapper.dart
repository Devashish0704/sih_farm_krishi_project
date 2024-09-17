import 'package:e_commerce_app_flutter/screens/home/home_screen.dart';
import 'package:e_commerce_app_flutter/screens/sign_in/sign_in_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthentificationWrapper extends StatefulWidget {
  static const String routeName = "/authentification_wrapper";

  @override
  _AuthentificationWrapperState createState() =>
      _AuthentificationWrapperState();
}

class _AuthentificationWrapperState extends State<AuthentificationWrapper> {
  bool _locationPermissionGranted = false;
  bool _locationPermissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
        _locationPermissionChecked = true;
      });
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        setState(() {
          _locationPermissionGranted = true;
        });
      }
      setState(() {
        _locationPermissionChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationPermissionChecked) {
      // Show a loading spinner while checking permissions
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_locationPermissionGranted) {
      // Show a screen explaining why location permission is needed and how to grant it
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Location permission is required to use this app.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkLocationPermission,
                child: Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    // Check authentication state once location permission is granted
    return StreamBuilder(
      stream: AuthentificationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
