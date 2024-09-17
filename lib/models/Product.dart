// import 'package:e_commerce_app_flutter/models/Model.dart';
// import 'package:enum_to_string/enum_to_string.dart';
// import 'package:geolocator/geolocator.dart';

// enum ProductType {
//   Cereals,
//   Pulses,
//   Fruits,
//   Vegetables,
//   Wastes,
//   Others,
// }

// class Product extends Model {
//   static const String IMAGES_KEY = "images";
//   static const String TITLE_KEY = "title";
//   static const String VARIANT_KEY = "variant";
//   // static const String DISCOUNT_PRICE_KEY = "discount_price";
//   static const String ORIGINAL_PRICE_KEY = "price";
//   static const String RATING_KEY = "rating";
//   static const String HIGHLIGHTS_KEY = "highlights";
//   static const String DESCRIPTION_KEY = "description";
//   static const String SELLER_KEY = "seed_company";
//   static const String OWNER_KEY = "owner";
//   static const String PRODUCT_TYPE_KEY = "product_type";
//   // static const String SEARCH_TAGS_KEY = "search_tags";

//   List<String>? images;
//   String? title;
//   String? variant;
//   num? price;
//   // num? originalPrice;
//   num rating;
//   String? highlights;
//   String? description;
//   String? seed_company;
//   bool favourite = false; // Initialize favourite to false by default
//    int? quantity;
//    String? quantityName; // Fixed typo from "quanityName" to "quantityName"
//   String? phoneNumber;
//   final Position position;
//   String? owner;
//   ProductType? productType;

//   Product(
//     String id,
//     {
//     this.images,
//     this.title,
//      this.quantity,
//     this.quantityName,
//     this.position,
//     this.variant,
//     this.productType,
//     this.price,
//     this.rating = 0.0,
//     this.highlights,
//     this.description,
//     this.seed_company,
//     this.owner,
//   }) : super(id);
// }

//   // int calculatePercentageDiscount() {
//   if (originalPrice == null || discountPrice == null || originalPrice == 0) {
//     return 0;
//   }
//   int discount =
//       (((originalPrice! - discountPrice!) * 100) / originalPrice!).round();
//   return discount;
// }

//   factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
//     return Product(
//       id ?? '',
//       images: (map[IMAGES_KEY] ?? []).cast<String>(),
//       title: map[TITLE_KEY],
//       variant: map[VARIANT_KEY],
//       productType:
//           EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
//       // discountPrice: map[DISCOUNT_PRICE_KEY],
//       price: map[ORIGINAL_PRICE_KEY],
//       rating: map[RATING_KEY] ?? 0.0,
//       highlights: map[HIGHLIGHTS_KEY],
//       description: map[DESCRIPTION_KEY],
//       seed_company: map[SELLER_KEY],
//       owner: map[OWNER_KEY],
//       //   searchTags: (map[SEARCH_TAGS_KEY] ?? []).cast<String>(),
//     );
//   }

//   @override
//   Map<String, dynamic> toMap() {
//     return {
//       IMAGES_KEY: images,
//       TITLE_KEY: title,
//       VARIANT_KEY: variant,
//       PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
//       // DISCOUNT_PRICE_KEY: discountPrice,
//       ORIGINAL_PRICE_KEY: price,
//       RATING_KEY: rating,
//       HIGHLIGHTS_KEY: highlights,
//       DESCRIPTION_KEY: description,
//       SELLER_KEY: seed_company,
//       OWNER_KEY: owner,
//       //    SEARCH_TAGS_KEY: searchTags,
//     };
//   }

//   @override
//   Map<String, dynamic> toUpdateMap() {
//     final map = <String, dynamic>{};
//     if (images != null) map[IMAGES_KEY] = images;
//     if (title != null) map[TITLE_KEY] = title;
//     if (variant != null) map[VARIANT_KEY] = variant;
//     //  if (discountPrice != null) map[DISCOUNT_PRICE_KEY] = discountPrice;
//     if (price != null) map[ORIGINAL_PRICE_KEY] = price;
//     map[RATING_KEY] = rating; // Always include rating
//     if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
//     if (description != null) map[DESCRIPTION_KEY] = description;
//     if (seed_company != null) map[SELLER_KEY] = seed_company;
//     if (productType != null) {
//       map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
//     }
//     if (owner != null) map[OWNER_KEY] = owner;
//     // if (searchTags != null) map[SEARCH_TAGS_KEY] = searchTags;

//     return map;
//   }
// }

import 'package:e_commerce_app_flutter/models/Model.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType {
  Cereals,
  Pulses,
  Fruits,
  Vegetables,
  Wastes,
  Others,
}

class Product extends Model {
  static const String IMAGES_KEY = "images";
  static const String TITLE_KEY = "title";
  static const String VARIANT_KEY = "variant";
  static const String ORIGINAL_PRICE_KEY = "price";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SELLER_KEY = "seed_company";
  static const String OWNER_KEY = "owner";
  static const String PRODUCT_TYPE_KEY = "product_type";

  List<String>? images;
  String? title;
  String? variant;
  num? price;
  num rating;
  String? highlights;
  String? description;
  String? seed_company;
  bool favourite = false;
  int? quantity;
  String? quantityName;
  String? phoneNumber;
  final Position position;
  String? owner;
  ProductType? productType;

  Product(
    String id, {
    this.images,
    this.title,
    this.quantity,
    this.quantityName,
    required this.position,
    this.variant,
    this.productType,
    this.price,
    this.rating = 0.0,
    this.highlights,
    this.description,
    this.seed_company,
    this.owner,
  }) : super(id);

  // Factory method to create a Product instance from Firestore
  factory Product.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Missing data for Product: ${snapshot.id}');
    }
    GeoPoint loc = data['position'];

    return Product(
      snapshot.id,
      images: List<String>.from(data[IMAGES_KEY] ?? []),
      title: data[TITLE_KEY] ?? '',
      variant: data[VARIANT_KEY] ?? '',
      price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
      rating: (data[RATING_KEY] ?? 0).toDouble(),
      highlights: data[HIGHLIGHTS_KEY] ?? '',
      description: data[DESCRIPTION_KEY] ?? '',
      seed_company: data[SELLER_KEY] ?? '',
      owner: data[OWNER_KEY] ?? '',
      productType:
          EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
      quantity: data['quantity'] ?? 0,
      quantityName: data['quantityName'] ?? '',
      position: Position(
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );
  }

  // Method to convert Product instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      IMAGES_KEY: this.images,
      TITLE_KEY: this.title,
      VARIANT_KEY: this.variant,
      ORIGINAL_PRICE_KEY: this.price,
      RATING_KEY: this.rating,
      HIGHLIGHTS_KEY: this.highlights,
      DESCRIPTION_KEY: this.description,
      SELLER_KEY: this.seed_company,
      OWNER_KEY: this.owner,
      PRODUCT_TYPE_KEY: EnumToString.convertToString(this.productType),
      'quantity': this.quantity,
      'quantityName': this.quantityName,
      'phoneNumber': this.phoneNumber,
      'position': GeoPoint(
        this.position.latitude,
        this.position.longitude,
      ),
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return toJson(); // Use the existing toJson method
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (images != null) map[IMAGES_KEY] = images;
    if (title != null) map[TITLE_KEY] = title;
    if (variant != null) map[VARIANT_KEY] = variant;
    if (price != null) map[ORIGINAL_PRICE_KEY] = price;
    map[RATING_KEY] = rating;
    if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (seed_company != null) map[SELLER_KEY] = seed_company;
    if (owner != null) map[OWNER_KEY] = owner;
    if (productType != null) {
      map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
    }
    if (quantity != null) map['quantity'] = quantity;
    if (quantityName != null) map['quantityName'] = quantityName;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    map['position'] = GeoPoint(position.latitude, position.longitude);
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map, {required String id}) {
    GeoPoint loc = map['position'] ?? GeoPoint(0, 0);
    return Product(
      id,
      images: List<String>.from(map[IMAGES_KEY] ?? []),
      title: map[TITLE_KEY] ?? '',
      variant: map[VARIANT_KEY] ?? '',
      price: (map[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
      rating: (map[RATING_KEY] ?? 0).toDouble(),
      highlights: map[HIGHLIGHTS_KEY] ?? '',
      description: map[DESCRIPTION_KEY] ?? '',
      seed_company: map[SELLER_KEY] ?? '',
      owner: map[OWNER_KEY] ?? '',
      productType:
          EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
      quantity: map['quantity'] ?? 0,
      quantityName: map['quantityName'] ?? '',
      position: Position(
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );
  }
}
