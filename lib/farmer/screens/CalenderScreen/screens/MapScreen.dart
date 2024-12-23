import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(), // Include required parameters
        accuracy: 1,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        buildingsEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        trafficEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(20.2961, 85.8245), // Default coordinates
          zoom: 16,
        ),
        onTap: (pos) => _selectLocation(pos),
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: MarkerId("Loc"),
                  position: LatLng(
                    _pickedLocation!.latitude,
                    _pickedLocation!.longitude,
                  ),
                ),
              },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        child: Icon(
          Icons.save,
          color: Colors.white,
        ),
        onPressed: () {
          if (_pickedLocation == null) {
            Fluttertoast.showToast(msg: "Please select a location!");
          } else {
            Navigator.of(context).pop(_pickedLocation);
          }
        },
      ),
    );
  }
}
