import 'package:e_commerce_app_flutter/screens/home/home_screen.dart';
//import 'package:e_commerce_app_flutter/farmer/screens/HomeScreen.dart';
import 'package:e_commerce_app_flutter/screens/sign_in/sign_in_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      await _showLocationServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationPermissionChecked = true;
          _locationPermissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog to open settings
      await _showPermissionDeniedDialog();
      setState(() {
        _locationPermissionChecked = true;
        _locationPermissionGranted = false;
      });
      return;
    }

    // Permission granted
    setState(() {
      _locationPermissionChecked = true;
      _locationPermissionGranted = true;
    });

    // Optionally get current position
    try {
      Position position = await Geolocator.getCurrentPosition();
      print('Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _showLocationServiceDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this app.'),
          actions: [
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
              'Location permission is permanently denied. Please go to settings to enable it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
