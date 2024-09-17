// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Product {
//   final String id;
//   String userId;
//   final String title;
//   final double price;
//   String imageUrl;
//   final int quantity;
//   final String quantityName; // Fixed typo from "quanityName" to "quantityName"
//   String phoneNumber;
//   final Position position;

//   Product({
//     this.id = " ",
//     this.userId = " ",
//     this.title = " ",
//     this.price = 0.0,
//     this.imageUrl = " ",
//     this.quantity = 1,
//     this.quantityName = " ",
//     this.phoneNumber = " ",
//     required this.position,
//   });

//   factory Product.fromFirestore(DocumentSnapshot snapshot) {
//     // Cast snapshot.data() to Map<String, dynamic>
//     final data = snapshot.data() as Map<String, dynamic>?;

//     if (data == null) {
//       throw StateError('Missing data for Product: ${snapshot.id}');
//     }
//     GeoPoint loc = data["position"];

//     return Product(
//       id: snapshot.id,
//       userId: data['userId'] ?? '',
//       title: data['title'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//       imageUrl: data['imageUrl'] ?? '',
//       quantity: data['quantity'] ?? 0,
//       quantityName: data['quantityName'] ?? '', // Fixed typo
//       phoneNumber: data['phoneNumber'] ?? '',
//       position: Position(
//         latitude: loc.latitude ?? 0.0,
//         longitude: loc.longitude ?? 0.0,
//         timestamp: DateTime.now(), // Default timestamp
//         accuracy: 0.0, // Default accuracy
//         altitude: 0.0, // Default altitude
//         heading: 0.0, // Default heading
//         speed: 0.0, // Default speed
//         speedAccuracy: 0.0, altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0, // Default speed accuracy
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': this.userId,
//       'title': this.title,
//       'price': this.price,
//       'imageUrl': this.imageUrl,
//       'quantity': this.quantity,
//       'quantityName': this.quantityName, // Fixed typo
//       'phoneNumber': this.phoneNumber,
//       'position': GeoPoint(
//         this.position.latitude,
//         this.position.longitude,
//       ),
//     };
//   }
// }
