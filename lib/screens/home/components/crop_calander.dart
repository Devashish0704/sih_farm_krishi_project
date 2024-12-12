import 'package:e_commerce_app_flutter/farmer/services/LocationService.dart';
import 'package:e_commerce_app_flutter/farmer/services/Mandi/mandiService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropCalendarScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Calendar'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cropfields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No crops found.'));
          }

          final crops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              Position position = Position(
                latitude: crop['position'].latitude,
                longitude: crop['position'].longitude,
                timestamp: DateTime.now(),
                accuracy: 0.0, // Assuming default or unknown accuracy
                altitude: 0.0, // Assuming default or unknown altitude
                altitudeAccuracy:
                    0.0, // Assuming default or unknown altitude accuracy
                heading: 0.0, // Assuming default or unknown heading
                headingAccuracy:
                    0.0, // Assuming default or unknown heading accuracy
                speed: 0.0, // Assuming default or unknown speed
                speedAccuracy:
                    0.0, // Assuming default or unknown speed accuracy
              );
              return FutureBuilder<String>(
                future: MandiService().getStateFromLocation(position),
                // LocationService.getPlaceAddress(
                //     position.latitude, position.longitude),
                builder: (context, geoSnapshot) {
                  String harvestDate = _calculateHarvestDate(
                    crop['startDate'].toDate(),
                    crop['harvestTime'],
                  );

                  if (geoSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return CropCard(
                    cropId: crop.id,
                    cropName: crop['crop'],
                    imageUrl: crop['imageUrl'],
                    address: geoSnapshot.data ?? 'Fetching location...',
                    startDate: crop['startDate'].toDate(),
                    harvestDate: harvestDate,
                    startTime: crop['startTime'],
                    booked: crop['booked'] ?? false,
                    onBook: () async {
                      await _firestore
                          .collection('cropfields')
                          .doc(crop.id)
                          .update({'booked': true});
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Calculates the harvest date by adding `harvestTime` to `startDate`
  String _calculateHarvestDate(DateTime startDate, int harvestTime) {
    final harvestDate = startDate.add(Duration(days: harvestTime));
    return "${harvestDate.year}-${_formatTwoDigits(harvestDate.month)}-${_formatTwoDigits(harvestDate.day)}";
  }

  /// Formats numbers to two digits (e.g., 5 -> 05)
  String _formatTwoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }
}

class CropCard extends StatelessWidget {
  final String cropId;
  final String cropName;
  final String imageUrl;
  final String address;
  final DateTime startDate;
  final String harvestDate;
  final String startTime;
  final bool booked;
  final VoidCallback onBook;

  CropCard({
    required this.cropId,
    required this.cropName,
    required this.imageUrl,
    required this.address,
    required this.startDate,
    required this.harvestDate,
    required this.startTime,
    required this.booked,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: EdgeInsets.all(10),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  cropName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('Location: $address'),
                Text(
                    'Start Date: ${startDate.toLocal().toString().split(' ')[0]}'),
                Text('Harvest Date: $harvestDate'),
                SizedBox(height: 10),
                if (!booked)
                  ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Book this Crop'),
                  ),
                if (booked)
                  Text(
                    'Already Booked',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (booked)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BOOKED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
