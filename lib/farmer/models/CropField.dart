// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CropField {
//   final String id;
//   final String crop;
//   final Position position;
//   final Timestamp startDate;
//   final String imageUrl;
//   final String startTime;
//   final int harvestTime;

//   const CropField({
//     required this.id,
//     required this.crop,
//     required this.position,
//     required this.startDate,
//     required this.startTime,
//     required this.imageUrl,
//     required this.harvestTime,
//   });

//   factory CropField.fromFirestore(DocumentSnapshot snapshot) {
//     final doc = snapshot.data;
//     final field = CropField(
//       id: snapshot.id,
//       crop: doc['crop'] ?? null,
//       position: Position(
//               latitude: doc['position'].latitude,
//               longitude: doc['position'].longitude) ??
//           null,
//       startDate: doc['startDate'] ?? null,
//       startTime: doc['startTime'] ?? null,
//       imageUrl: doc['imageUrl'] ?? null,
//       harvestTime: doc['harvestTime'] ?? null,
//     );
//     return field;
//   }
// }
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CropField {
  final String id;
  final String crop;
  final Position position;
  final Timestamp startDate;
  final String imageUrl;
  final String startTime;
  final int harvestTime;

  const CropField({
    required this.id,
    required this.crop,
    required this.position,
    required this.startDate,
    required this.startTime,
    required this.imageUrl,
    required this.harvestTime,
  });

  factory CropField.fromFirestore(DocumentSnapshot snapshot) {
    // Cast snapshot.data() to a Map<String, dynamic>
    final doc = snapshot.data() as Map<String, dynamic>?;

    if (doc == null) {
      // Handle the case where doc is null
      throw StateError('Missing data for CropField: ${snapshot.id}');
    }

    GeoPoint loc = doc['position'] ?? [0.0, 0.0];

    return CropField(
      id: snapshot.id,
      crop: doc['crop'] ?? '',
      position: Position(
        latitude: loc.latitude ?? 0.0,
        longitude: loc.longitude ?? 0.0,
        timestamp: DateTime.now(), // Add a default timestamp if needed
        accuracy: 0.0, // Default accuracy
        altitude: 0.0, // Default altitude
        heading: 0.0, // Default heading
        speed: 0.0, // Default speed
        speedAccuracy: 0.0, altitudeAccuracy: 0.0,
        headingAccuracy: 0.0, // Default speed accuracy
      ),
      startDate: doc['startDate'] ?? Timestamp.now(),
      startTime: doc['startTime'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
      harvestTime: doc['harvestTime'] ?? 0,
    );
  }
}
