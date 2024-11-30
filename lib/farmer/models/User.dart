import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';

class User {
  final String userId;
  final String name;
  final int age;
  final String phone;
  final String imageUrl;
  final String city;
  final Position location;
  final String aadharNo;
  final String fieldId;

  User({
    required this.userId,
    required this.name,
    required this.age,
    required this.phone,
    required this.city,
    required this.aadharNo,
    required this.location,
    required this.imageUrl,
    required this.fieldId,
  });

  factory User.fromFirestore(DocumentSnapshot snapshot) {
    // Cast snapshot.data() to Map<String, dynamic>

    final data = snapshot.data() as Map<String, dynamic>?;
    // print(data!["location"]["latitide"]);

    if (data == null) {
      throw StateError('Missing data for User: ${snapshot.id}');
    }
    print(data);

    // GeoPoint loc = data["location"];
    GeoPoint loc = data["location"] != null ? data["location"] : GeoPoint(0, 0);
    print("loc lat yo ${loc.latitude}");

    return User(
      userId: snapshot.id, // Use snapshot.id for document ID
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      aadharNo: data['aadharNumber'] ?? '',
      imageUrl: data['imageUrl'] ?? STOCK_IMAGE_URL,
      location: Position(
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: DateTime.now(), // Provide a default timestamp
        accuracy: 0.0, // Provide a default accuracy
        altitude: 0.0, // Provide a default altitude
        heading: 0.0, // Provide a default heading
        speed: 0.0, // Provide a default speed
        speedAccuracy: 0.0, altitudeAccuracy: 0.0,
        headingAccuracy: 0.0, // Provide a default speed accuracy
      ),
      fieldId: data['fieldId'] ?? '',
    );
  }
}
