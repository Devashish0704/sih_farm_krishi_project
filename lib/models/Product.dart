import 'package:e_commerce_app_flutter/models/Model.dart';
import 'package:e_commerce_app_flutter/screens/home/components/categories.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType {
  freshProduce, // Fresh fruits and vegetables
  grainsAndPulses, // Grains, cereals, and pulses
  dairyProducts, // Milk, cheese, yogurt, etc.
  meatAndPoultry, // Chicken, eggs, fish, etc.
  organicProducts, // Organic fruits, vegetables, honey, etc.
  processedProducts, // Flour, pickles, dried fruits, etc.
  spicesAndHerbs, // Spices like turmeric, cumin, etc.
  flowersAndPlants, // Fresh flowers, potted plants, seeds
  beverages, // Juices, herbal teas, etc.
  animalFeed, // Cattle, poultry, and fish feed
  fertilizersAndManure, // Organic fertilizers, vermicompost, etc.
  miscellaneous, // Honey, natural oils, handcrafted items
}

class Product extends Model {
  static const String IMAGES_KEY = "images";
  static const String NAME_KEY = "name";
  static const String CATEGORY_KEY = "category";
  static const String VARIANT_KEY = "variant";
  static const String ORIGINAL_PRICE_KEY = "price";
  static const String PREDICTIVE_PRICE_KEY = "predictiveprice";
  static const String POINT_RATING_KEY = "pointRating";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SEED_KEY = "seed_company";
  static const String OWNER_KEY = "owner";
  static const String PRODUCT_TYPE_KEY = "product_type";
  static const String HARVEST_DATE_KEY = "harvestDate";
  static const String IS_ORGANIC_KEY = "isOrganic";
  static const String CERTIFICATION_IMAGES_KEY = "certificationImages";
  static const String STORAGE_METHOD_KEY = "storageMethod";
  static const String GRADE_KEY = "grade";
  static const String MINIMUM_ORDER_QUANTITY_KEY = "minimumOrderQuantity";
  static const String IS_PRICE_NEGOTIABLE_KEY = "isPriceNegotiable";
  static const String IS_DELIVERY_AVAILABLE_KEY = "isDeliveryAvailable";

  String? name = '';
  String? category;
  String? variant;
  num? price;
  num? predictivePrice;
  num? pointRating;
  num? rating = 5;
  String? highlights;
  String? description;
  String? seed_company;
  bool favourite = false;
  int? quantity;
  String? quantityName;
  String? phoneNumber;
  Position position; // Required non-nullable field
  String? owner;
  ProductType? productType;
  DateTime? harvestDate;
  bool? isOrganic = false;
  List<String>? certificationImages;
  List<String>? images;
  String? storageMethod;
  String? grade;
  int? minimumOrderQuantity;
  bool? isPriceNegotiable;
  bool? isDeliveryAvailable;

  Product(
    String id, {
    this.images,
    this.name,
    this.category,
    this.variant,
    this.price,
    this.predictivePrice,
    this.pointRating,
    this.rating = 5,
    this.highlights,
    this.description,
    this.seed_company,
    this.owner,
    this.quantity,
    this.quantityName,
    this.phoneNumber,
    required this.position,
    this.productType,
    this.harvestDate,
    this.isOrganic,
    this.certificationImages,
    this.storageMethod,
    this.grade,
    this.minimumOrderQuantity,
    this.isPriceNegotiable,
    this.isDeliveryAvailable,
    this.favourite = false,
  }) : super(id);

  factory Product.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final loc = data['position'] as GeoPoint?;

    return Product(
      snapshot.id,
      images: List<String>.from(data[IMAGES_KEY] ?? []),
      certificationImages:
          List<String>.from(data[CERTIFICATION_IMAGES_KEY] ?? []),
      name: data[NAME_KEY] as String? ?? '',
      category: data[CATEGORY_KEY] as String? ?? '',
      variant: data[VARIANT_KEY] as String?,
      price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
      predictivePrice: (data[PREDICTIVE_PRICE_KEY] ?? 0).toDouble(),
      pointRating: (data[POINT_RATING_KEY] ?? 0).toDouble(),
      rating: (data[RATING_KEY] ?? 0).toDouble(),
      highlights: data[HIGHLIGHTS_KEY] as String?,
      description: data[DESCRIPTION_KEY] as String?,
      seed_company: data[SEED_KEY] as String?,
      owner: data[OWNER_KEY] as String?,
      productType:
          EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
      quantity: data['quantity'] as int?,
      quantityName: data['quantityName'] as String?,
      position: loc != null
          ? Position(
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
            )
          : throw StateError("Position is required"),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return toJson(); // Use the existing toJson method
  }

  factory Product.fromMap(Map<String, dynamic> data, {required String id}) {
    final loc = data['position'] as GeoPoint?;

    return Product(
      id,
      images: List<String>.from(data[IMAGES_KEY] ?? []),
      name: data[NAME_KEY] as String? ?? '',
      category: data[CATEGORY_KEY] as String? ?? '',
      variant: data[VARIANT_KEY] as String?,
      price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
      predictivePrice: (data[PREDICTIVE_PRICE_KEY] ?? 0).toDouble(),
      pointRating: (data[POINT_RATING_KEY] ?? 0).toDouble(),
      rating: (data[RATING_KEY] ?? 0).toDouble(),
      highlights: data[HIGHLIGHTS_KEY] as String?,
      description: data[DESCRIPTION_KEY] as String?,
      seed_company: data[SEED_KEY] as String?,
      owner: data[OWNER_KEY] as String?,
      productType:
          EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
      quantity: data['quantity'] as int?,
      quantityName: data['quantityName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      position: loc != null
          ? Position(
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
            )
          : throw StateError("Position is required"),
      harvestDate: data[HARVEST_DATE_KEY] != null
          ? DateTime.tryParse(data[HARVEST_DATE_KEY])
          : null,
      isOrganic: data[IS_ORGANIC_KEY] as bool?,
      certificationImages:
          List<String>.from(data[CERTIFICATION_IMAGES_KEY] ?? []),
      storageMethod: data[STORAGE_METHOD_KEY] as String?,
      grade: data[GRADE_KEY] as String?,
      minimumOrderQuantity: data[MINIMUM_ORDER_QUANTITY_KEY] as int?,
      isPriceNegotiable: data[IS_PRICE_NEGOTIABLE_KEY] as bool?,
      isDeliveryAvailable: data[IS_DELIVERY_AVAILABLE_KEY] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      IMAGES_KEY: images,
      NAME_KEY: name,
      CATEGORY_KEY: category,
      VARIANT_KEY: variant,
      ORIGINAL_PRICE_KEY: price,
      PREDICTIVE_PRICE_KEY: predictivePrice,
      POINT_RATING_KEY: pointRating,
      RATING_KEY: rating,
      HIGHLIGHTS_KEY: highlights,
      DESCRIPTION_KEY: description,
      SEED_KEY: seed_company,
      OWNER_KEY: owner,
      PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
      'quantity': quantity,
      'quantityName': quantityName,
      'phoneNumber': phoneNumber,
      'position': GeoPoint(position.latitude, position.longitude),
      HARVEST_DATE_KEY: harvestDate?.toIso8601String(),
      IS_ORGANIC_KEY: isOrganic,
      CERTIFICATION_IMAGES_KEY: certificationImages,
      STORAGE_METHOD_KEY: storageMethod,
      GRADE_KEY: grade,
      MINIMUM_ORDER_QUANTITY_KEY: minimumOrderQuantity,
      IS_PRICE_NEGOTIABLE_KEY: isPriceNegotiable,
      IS_DELIVERY_AVAILABLE_KEY: isDeliveryAvailable,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (images != null) map[IMAGES_KEY] = images;
    if (name != null) map[NAME_KEY] = name;
    if (category != null) map[CATEGORY_KEY] = category;
    if (variant != null) map[VARIANT_KEY] = variant;
    if (price != null) map[ORIGINAL_PRICE_KEY] = price;
    if (predictivePrice != null) map[PREDICTIVE_PRICE_KEY] = predictivePrice;
    if (pointRating != null) map[POINT_RATING_KEY] = pointRating;
    map[RATING_KEY] = rating;
    if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (seed_company != null) map[NAME_KEY] = seed_company;
    if (owner != null) map[OWNER_KEY] = owner;
    if (productType != null) {
      map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
    }
    if (quantity != null) map['quantity'] = quantity;
    if (quantityName != null) map['quantityName'] = quantityName;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    map['position'] = GeoPoint(position.latitude, position.longitude);
    if (harvestDate != null)
      map[HARVEST_DATE_KEY] = harvestDate?.toIso8601String();
    if (isOrganic != null) map[IS_ORGANIC_KEY] = isOrganic;
    if (certificationImages != null)
      map[CERTIFICATION_IMAGES_KEY] = certificationImages;
    if (storageMethod != null) map[STORAGE_METHOD_KEY] = storageMethod;
    if (grade != null) map[GRADE_KEY] = grade;
    if (minimumOrderQuantity != null)
      map[MINIMUM_ORDER_QUANTITY_KEY] = minimumOrderQuantity;
    if (isPriceNegotiable != null)
      map[IS_PRICE_NEGOTIABLE_KEY] = isPriceNegotiable;
    if (isDeliveryAvailable != null)
      map[IS_DELIVERY_AVAILABLE_KEY] = isDeliveryAvailable;

    return map;
  }
}





// import 'package:e_commerce_app_flutter/models/Model.dart';
// import 'package:enum_to_string/enum_to_string.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

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
//   static const String ORIGINAL_PRICE_KEY = "price";
//   static const String RATING_KEY = "rating";
//   static const String HIGHLIGHTS_KEY = "highlights";
//   static const String DESCRIPTION_KEY = "description";
//   static const String SELLER_KEY = "seed_company";
//   static const String OWNER_KEY = "owner";
//   static const String PRODUCT_TYPE_KEY = "product_type";
//   static const String HARVEST_DATE_KEY = "harvestDate";
//   static const String IS_ORGANIC_KEY = "isOrganic";
//   static const String LOCATION_NAME_KEY = "locationName";
//   static const String MOISTURE_CONTENT_KEY = "moistureContent";
//   static const String NUTRITIONAL_INFO_KEY = "nutritionalInfo";
//   static const String CERTIFICATION_IMAGES_KEY = "certificationImages";
//   static const String STORAGE_METHOD_KEY = "storageMethod";
//   static const String GRADE_KEY = "grade";
//   static const String MINIMUM_ORDER_QUANTITY_KEY = "minimumOrderQuantity";
//   static const String IS_PRICE_NEGOTIABLE_KEY = "isPriceNegotiable";
//   static const String IS_DELIVERY_AVAILABLE_KEY = "isDeliveryAvailable";

//   List<String>? images;
//   String? title;
//   String? variant;
//   num? price;
//   num rating;
//   String? highlights;
//   String? description;
//   String? seed_company;
//   bool favourite;
//   int? quantity;
//   String? quantityName;
//   String? phoneNumber;
//   late final Position position; // Required non-nullable field
//   String? owner;
//   ProductType? productType;
//   DateTime? harvestDate;
//   bool? isOrganic;
//   String? locationName;
//   double? moistureContent;
//   Map<String, dynamic>? nutritionalInfo;
//   List<String>? certificationImages;
//   String? storageMethod;
//   String? grade;
//   int? minimumOrderQuantity;
//   bool? isPriceNegotiable;
//   bool? isDeliveryAvailable;

//   Product(
//     String id, {
//     this.images,
//     this.title,
//     this.variant,
//     this.price,
//     this.rating = 0.0,
//     this.highlights,
//     this.description,
//     this.seed_company,
//     this.owner,
//     this.quantity,
//     this.quantityName,
//     this.phoneNumber,
//     required this.position,
//     this.productType,
//     this.harvestDate,
//     this.isOrganic,
//     this.locationName,
//     this.moistureContent,
//     this.nutritionalInfo,
//     this.certificationImages,
//     this.storageMethod,
//     this.grade,
//     this.minimumOrderQuantity,
//     this.isPriceNegotiable,
//     this.isDeliveryAvailable,
//     this.favourite = false,
//   }) : super(id);

//   factory Product.fromFirestore(DocumentSnapshot snapshot) {
//     final data = snapshot.data() as Map<String, dynamic>? ?? {};
//     final loc = data['position'] as GeoPoint?;

//     return Product(
//       snapshot.id,
//       images: List<String>.from(data[IMAGES_KEY] ?? []),
//       title: data[TITLE_KEY] as String? ?? '',
//       variant: data[VARIANT_KEY] as String?,
//       price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
//       rating: (data[RATING_KEY] ?? 0).toDouble(),
//       highlights: data[HIGHLIGHTS_KEY] as String?,
//       description: data[DESCRIPTION_KEY] as String?,
//       seed_company: data[SELLER_KEY] as String?,
//       owner: data[OWNER_KEY] as String?,
//       productType:
//           EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
//       quantity: data['quantity'] as int?,
//       quantityName: data['quantityName'] as String?,
//       position: loc != null
//           ? Position(
//               latitude: loc.latitude,
//               longitude: loc.longitude,
//               timestamp: DateTime.now(),
//               accuracy: 0.0,
//               altitude: 0.0,
//               heading: 0.0,
//               speed: 0.0,
//               speedAccuracy: 0.0,
//               altitudeAccuracy: 0.0,
//               headingAccuracy: 0.0,
//             )
//           : throw StateError("Position is required"),
//     );
//   }

//   @override
//   Map<String, dynamic> toMap() {
//     return toJson(); // Use the existing toJson method
//   }

//   factory Product.fromMap(Map<String, dynamic> data, {required String id}) {
//     final loc = data['position'] as GeoPoint?;

//     return Product(
//       id,
//       images: List<String>.from(data[IMAGES_KEY] ?? []),
//       title: data[TITLE_KEY] as String? ?? '',
//       variant: data[VARIANT_KEY] as String?,
//       price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
//       rating: (data[RATING_KEY] ?? 0).toDouble(),
//       highlights: data[HIGHLIGHTS_KEY] as String?,
//       description: data[DESCRIPTION_KEY] as String?,
//       seed_company: data[SELLER_KEY] as String?,
//       owner: data[OWNER_KEY] as String?,
//       productType:
//           EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
//       quantity: data['quantity'] as int?,
//       quantityName: data['quantityName'] as String?,
//       phoneNumber: data['phoneNumber'] as String?,
//       position: loc != null
//           ? Position(
//               latitude: loc.latitude,
//               longitude: loc.longitude,
//               timestamp: DateTime.now(),
//               accuracy: 0.0,
//               altitude: 0.0,
//               heading: 0.0,
//               speed: 0.0,
//               speedAccuracy: 0.0,
//               altitudeAccuracy: 0.0,
//               headingAccuracy: 0.0,
//             )
//           : throw StateError("Position is required"),
//       harvestDate: data[HARVEST_DATE_KEY] != null
//           ? DateTime.tryParse(data[HARVEST_DATE_KEY])
//           : null,
//       isOrganic: data[IS_ORGANIC_KEY] as bool?,
//       locationName: data[LOCATION_NAME_KEY] as String?,
//       moistureContent: (data[MOISTURE_CONTENT_KEY] as num?)?.toDouble(),
//       nutritionalInfo: data[NUTRITIONAL_INFO_KEY] as Map<String, dynamic>?,
//       certificationImages:
//           List<String>.from(data[CERTIFICATION_IMAGES_KEY] ?? []),
//       storageMethod: data[STORAGE_METHOD_KEY] as String?,
//       grade: data[GRADE_KEY] as String?,
//       minimumOrderQuantity: data[MINIMUM_ORDER_QUANTITY_KEY] as int?,
//       isPriceNegotiable: data[IS_PRICE_NEGOTIABLE_KEY] as bool?,
//       isDeliveryAvailable: data[IS_DELIVERY_AVAILABLE_KEY] as bool?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       IMAGES_KEY: images,
//       TITLE_KEY: title,
//       VARIANT_KEY: variant,
//       ORIGINAL_PRICE_KEY: price,
//       RATING_KEY: rating,
//       HIGHLIGHTS_KEY: highlights,
//       DESCRIPTION_KEY: description,
//       SELLER_KEY: seed_company,
//       OWNER_KEY: owner,
//       PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
//       'quantity': quantity,
//       'quantityName': quantityName,
//       'phoneNumber': phoneNumber,
//       'position': GeoPoint(position.latitude, position.longitude),
//       HARVEST_DATE_KEY: harvestDate?.toIso8601String(),
//       IS_ORGANIC_KEY: isOrganic,
//       LOCATION_NAME_KEY: locationName,
//       MOISTURE_CONTENT_KEY: moistureContent,
//       NUTRITIONAL_INFO_KEY: nutritionalInfo,
//       CERTIFICATION_IMAGES_KEY: certificationImages,
//       STORAGE_METHOD_KEY: storageMethod,
//       GRADE_KEY: grade,
//       MINIMUM_ORDER_QUANTITY_KEY: minimumOrderQuantity,
//       IS_PRICE_NEGOTIABLE_KEY: isPriceNegotiable,
//       IS_DELIVERY_AVAILABLE_KEY: isDeliveryAvailable,
//     };
//   }

//   Map<String, dynamic> toUpdateMap() {
//     final map = <String, dynamic>{};
//     if (images != null) map[IMAGES_KEY] = images;
//     if (title != null) map[TITLE_KEY] = title;
//     if (variant != null) map[VARIANT_KEY] = variant;
//     if (price != null) map[ORIGINAL_PRICE_KEY] = price;
//     map[RATING_KEY] = rating;
//     if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
//     if (description != null) map[DESCRIPTION_KEY] = description;
//     if (seed_company != null) map[SELLER_KEY] = seed_company;
//     if (owner != null) map[OWNER_KEY] = owner;
//     if (productType != null) {
//       map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
//     }
//     if (quantity != null) map['quantity'] = quantity;
//     if (quantityName != null) map['quantityName'] = quantityName;
//     if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
//     map['position'] = GeoPoint(position.latitude, position.longitude);
//     if (harvestDate != null)
//       map[HARVEST_DATE_KEY] = harvestDate?.toIso8601String();
//     if (isOrganic != null) map[IS_ORGANIC_KEY] = isOrganic;
//     if (locationName != null) map[LOCATION_NAME_KEY] = locationName;
//     if (moistureContent != null) map[MOISTURE_CONTENT_KEY] = moistureContent;
//     if (nutritionalInfo != null) map[NUTRITIONAL_INFO_KEY] = nutritionalInfo;
//     if (certificationImages != null)
//       map[CERTIFICATION_IMAGES_KEY] = certificationImages;
//     if (storageMethod != null) map[STORAGE_METHOD_KEY] = storageMethod;
//     if (grade != null) map[GRADE_KEY] = grade;
//     if (minimumOrderQuantity != null)
//       map[MINIMUM_ORDER_QUANTITY_KEY] = minimumOrderQuantity;
//     if (isPriceNegotiable != null)
//       map[IS_PRICE_NEGOTIABLE_KEY] = isPriceNegotiable;
//     if (isDeliveryAvailable != null)
//       map[IS_DELIVERY_AVAILABLE_KEY] = isDeliveryAvailable;

//     return map;
//   }
// }






// // import 'package:e_commerce_app_flutter/models/Model.dart';
// // import 'package:enum_to_string/enum_to_string.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // enum ProductType {
// //   Cereals,
// //   Pulses,
// //   Fruits,
// //   Vegetables,
// //   Wastes,
// //   Others,
// // }

// // class Product extends Model {
// //   static const String IMAGES_KEY = "images";
// //   static const String TITLE_KEY = "title";
// //   static const String VARIANT_KEY = "variant";
// //   static const String ORIGINAL_PRICE_KEY = "price";
// //   static const String RATING_KEY = "rating";
// //   static const String HIGHLIGHTS_KEY = "highlights";
// //   static const String DESCRIPTION_KEY = "description";
// //   static const String SELLER_KEY = "seed_company";
// //   static const String OWNER_KEY = "owner";
// //   static const String PRODUCT_TYPE_KEY = "product_type";

// //   List<String>? images;
// //   String? title;
// //   String? variant;
// //   num? price;
// //   num rating;
// //   String? highlights;
// //   String? description;
// //   String? seed_company;
// //   bool favourite = false;
// //   int? quantity;
// //   String? quantityName;
// //   String? phoneNumber;
// //   final Position position;
// //   String? owner;
// //   ProductType? productType;

// //   Product(
// //     String id, {
// //     this.images,
// //     this.title,
// //     this.quantity,
// //     this.quantityName,
// //     required this.position,
// //     this.variant,
// //     this.productType,
// //     this.price,
// //     this.rating = 0.0,
// //     this.highlights,
// //     this.description,
// //     this.seed_company,
// //     this.owner,
// //   }) : super(id);

// //   // Factory method to create a Product instance from Firestore
// //   factory Product.fromFirestore(DocumentSnapshot snapshot) {
// //     final data = snapshot.data() as Map<String, dynamic>?;

// //     if (data == null) {
// //       throw StateError('Missing data for Product: ${snapshot.id}');
// //     }
// //     GeoPoint loc = data['position'];

// //     return Product(
// //       snapshot.id,
// //       images: List<String>.from(data[IMAGES_KEY] ?? []),
// //       title: data[TITLE_KEY] ?? '',
// //       variant: data[VARIANT_KEY] ?? '',
// //       price: (data[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
// //       rating: (data[RATING_KEY] ?? 0).toDouble(),
// //       highlights: data[HIGHLIGHTS_KEY] ?? '',
// //       description: data[DESCRIPTION_KEY] ?? '',
// //       seed_company: data[SELLER_KEY] ?? '',
// //       owner: data[OWNER_KEY] ?? '',
// //       productType:
// //           EnumToString.fromString(ProductType.values, data[PRODUCT_TYPE_KEY]),
// //       quantity: data['quantity'] ?? 0,
// //       quantityName: data['quantityName'] ?? '',
// //       position: Position(
// //         latitude: loc.latitude,
// //         longitude: loc.longitude,
// //         timestamp: DateTime.now(),
// //         accuracy: 0.0,
// //         altitude: 0.0,
// //         heading: 0.0,
// //         speed: 0.0,
// //         speedAccuracy: 0.0,
// //         altitudeAccuracy: 0.0,
// //         headingAccuracy: 0.0,
// //       ),
// //     );
// //   }

// //   // Method to convert Product instance to a JSON map for Firestore
// //   Map<String, dynamic> toJson() {
// //     return {
// //       IMAGES_KEY: this.images,
// //       TITLE_KEY: this.title,
// //       VARIANT_KEY: this.variant,
// //       ORIGINAL_PRICE_KEY: this.price,
// //       RATING_KEY: this.rating,
// //       HIGHLIGHTS_KEY: this.highlights,
// //       DESCRIPTION_KEY: this.description,
// //       SELLER_KEY: this.seed_company,
// //       OWNER_KEY: this.owner,
// //       PRODUCT_TYPE_KEY: EnumToString.convertToString(this.productType),
// //       'quantity': this.quantity,
// //       'quantityName': this.quantityName,
// //       'phoneNumber': this.phoneNumber,
// //       'position': GeoPoint(
// //         this.position.latitude,
// //         this.position.longitude,
// //       ),
// //     };
// //   }

// //   @override
// //   Map<String, dynamic> toMap() {
// //     return toJson(); // Use the existing toJson method
// //   }

// //   @override
// //   Map<String, dynamic> toUpdateMap() {
// //     final map = <String, dynamic>{};
// //     if (images != null) map[IMAGES_KEY] = images;
// //     if (title != null) map[TITLE_KEY] = title;
// //     if (variant != null) map[VARIANT_KEY] = variant;
// //     if (price != null) map[ORIGINAL_PRICE_KEY] = price;
// //     map[RATING_KEY] = rating;
// //     if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
// //     if (description != null) map[DESCRIPTION_KEY] = description;
// //     if (seed_company != null) map[SELLER_KEY] = seed_company;
// //     if (owner != null) map[OWNER_KEY] = owner;
// //     if (productType != null) {
// //       map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
// //     }
// //     if (quantity != null) map['quantity'] = quantity;
// //     if (quantityName != null) map['quantityName'] = quantityName;
// //     if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
// //     map['position'] = GeoPoint(position.latitude, position.longitude);
// //     return map;
// //   }

// //   factory Product.fromMap(Map<String, dynamic> map, {required String id}) {
// //     GeoPoint loc = map['position'] ?? GeoPoint(0, 0);
// //     return Product(
// //       id,
// //       images: List<String>.from(map[IMAGES_KEY] ?? []),
// //       title: map[TITLE_KEY] ?? '',
// //       variant: map[VARIANT_KEY] ?? '',
// //       price: (map[ORIGINAL_PRICE_KEY] ?? 0).toDouble(),
// //       rating: (map[RATING_KEY] ?? 0).toDouble(),
// //       highlights: map[HIGHLIGHTS_KEY] ?? '',
// //       description: map[DESCRIPTION_KEY] ?? '',
// //       seed_company: map[SELLER_KEY] ?? '',
// //       owner: map[OWNER_KEY] ?? '',
// //       productType:
// //           EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
// //       quantity: map['quantity'] ?? 0,
// //       quantityName: map['quantityName'] ?? '',
// //       position: Position(
// //         latitude: loc.latitude,
// //         longitude: loc.longitude,
// //         timestamp: DateTime.now(),
// //         accuracy: 0.0,
// //         altitude: 0.0,
// //         heading: 0.0,
// //         speed: 0.0,
// //         speedAccuracy: 0.0,
// //         altitudeAccuracy: 0.0,
// //         headingAccuracy: 0.0,
// //       ),
// //     );
// //   }
// // }
