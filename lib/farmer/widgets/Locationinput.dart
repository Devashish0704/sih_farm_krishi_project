import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/CalenderScreen/screens/MapScreen.dart';
import '../widgets/LightIconButton.dart';

class LocationInput extends StatefulWidget {
  final Function selectPlace;
  final Position? position;
  final bool isEnglish;

  LocationInput(this.selectPlace, {this.position, this.isEnglish = true});

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    getExistingLocation();
  }

  void getExistingLocation() {
    if (widget.position != null) {
      setState(() {
        _previewImageUrl = '';
      });
    }
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      // Check if the location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show error message if location services are disabled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEnglish
                ? 'Location services are disabled.'
                : 'स्थान सेवाएं अक्षम हैं।'),
          ),
        );
        return;
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Show error message if permission is denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEnglish
                  ? 'Location permissions are denied.'
                  : 'स्थान अनुमतियां अस्वीकृत हैं।'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Show error message if permission is denied forever
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEnglish
                ? 'Location permissions are permanently denied.'
                : 'स्थान अनुमतियां स्थायी रूप से अस्वीकृत हैं।'),
          ),
        );
        return;
      }

      // Get the current position
      final Position myLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _previewImageUrl =
            ''; // You may update this to a URL or image representation of the location
      });
      widget.selectPlace(myLocation.latitude, myLocation.longitude);
    } catch (error) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEnglish
              ? 'Failed to get location.'
              : 'स्थान प्राप्त करने में विफल।'),
        ),
      );
      print(error);
    }
  }

  Future<void> _selectOnMap() async {
    try {
      final Position? selectedLocation = await Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => MapScreen()),
      );
      if (selectedLocation == null) {
        return;
      }
      setState(() {
        _previewImageUrl = ''; // Update to show selected location
      });
      widget.selectPlace(selectedLocation.latitude, selectedLocation.longitude);
    } catch (error) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEnglish
              ? 'Failed to select location on map.'
              : 'नक्शे पर स्थान चुनने में विफल।'),
        ),
      );
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            height: 100,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              color: _previewImageUrl == null
                  ? Colors.red.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
            ),
            child: _previewImageUrl == null
                ? Text(widget.isEnglish ? "Select Location" : "स्थान चुनें")
                : Text(widget.isEnglish ? "Location Selected" : "स्थान चयनित"),
            alignment: Alignment.center,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              LightIconButton(
                icon: Icons.my_location,
                text: widget.isEnglish ? "My Location" : "मेरा स्थान",
                function: _getCurrentUserLocation,
              ),
              LightIconButton(
                icon: Icons.location_on,
                text: widget.isEnglish ? "Pick on Map" : "नक्शे पर चुनें",
                function: _selectOnMap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
