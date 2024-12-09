// import 'Model.dart';

import 'Model.dart';

class OrderedProduct extends Model {
  static const String PRODUCT_UID_KEY = "product_uid";
  static const String ORDER_DATE_KEY = "order_date";
  static const String PAYMENT_STATUS_KEY = "payment_status";
  static const String ORDER_STATUS_KEY = "order_status";

  // Defined order status enum to ensure consistent status progression
  static const List<String> orderStatusFlow = [
    'Ordered',
    'Processing',
    'Shipped',
    'Delivered',
    'Completed'
  ];

  String? productUid;
  String? orderDate;
  String? paymentStatus;
  String? sellerId;
  String? buyerId;
  String? orderStatus;
  int? quantity;

  OrderedProduct(
    String id, {
    this.productUid,
    this.orderDate,
    this.paymentStatus = "NA",
    this.sellerId,
    this.buyerId,
    this.orderStatus = "Pending",
    this.quantity,
  }) : super(id);

  factory OrderedProduct.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderedProduct(
      id!,
      productUid: map[PRODUCT_UID_KEY],
      orderDate: map[ORDER_DATE_KEY],
      paymentStatus: map[PAYMENT_STATUS_KEY],
      sellerId: map['seller_id'],
      buyerId: map['buyer_id'],
      orderStatus: map[ORDER_STATUS_KEY] ?? "Pending",
      quantity: map['quantity'],
    );
  }

  // Method to check if a status is valid and can be updated
  bool canUpdateStatus(String newStatus) {
    int currentIndex = orderStatusFlow.indexOf(orderStatus ?? 'Pending');
    int newStatusIndex = orderStatusFlow.indexOf(newStatus);

    // Allow moving forward or cancelling
    return newStatusIndex > currentIndex || newStatus == 'Cancelled';
  }

  // Method to get the list of completed statuses
  List<String> getCompletedStatuses() {
    if (orderStatus == null) return [];

    int currentStatusIndex = orderStatusFlow.indexOf(orderStatus!);
    return orderStatusFlow.sublist(0, currentStatusIndex + 1);
  }

  // Update order status with validation
  void updateOrderStatus(String newStatus) {
    if (canUpdateStatus(newStatus)) {
      orderStatus = newStatus;
    } else {
      throw Exception(
          'Invalid status update. Cannot move backwards in order status.');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      PRODUCT_UID_KEY: productUid,
      ORDER_DATE_KEY: orderDate,
      PAYMENT_STATUS_KEY: paymentStatus,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      ORDER_STATUS_KEY: orderStatus ?? "Pending",
      'quantity': quantity,
    };

    if (sellerId != null) map['seller_id'] = sellerId;
    if (buyerId != null) map['buyer_id'] = buyerId;

    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};

    if (productUid != null) map[PRODUCT_UID_KEY] = productUid;
    if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
    if (paymentStatus != null) map[PAYMENT_STATUS_KEY] = paymentStatus;
    if (buyerId != null) map["buyer_id"] = buyerId;
    if (sellerId != null) map["seller_id"] = sellerId;
    if (orderStatus != null) map[ORDER_STATUS_KEY] = orderStatus;
    if (quantity != null) map['quantity'] = quantity;

    return map;
  }
}


// class OrderedProduct extends Model {
//   static const String PRODUCT_UID_KEY = "product_uid";
//   static const String ORDER_DATE_KEY = "order_date";
//   static const String PAYMENT_STATUS_KEY = "payment_status";
//   static const String ORDER_STATUS_KEY = "order_status";

//   String? productUid;
//   String? orderDate;
//   String? paymentStatus;
//   String? sellerId;
//   String? buyerId;
//   String? orderStatus;
//   int? quantity;

//   OrderedProduct(
//     String id, {
//     this.productUid,
//     this.orderDate,
//     this.paymentStatus = "NA",
//     this.sellerId,
//     this.buyerId,
//     this.orderStatus = "NA",
//     this.quantity,
//   }) : super(id);

//   factory OrderedProduct.fromMap(Map<String, dynamic> map, {String? id}) {
//     return OrderedProduct(id!,
//         productUid: map[PRODUCT_UID_KEY],
//         orderDate: map[ORDER_DATE_KEY],
//         paymentStatus: map[PAYMENT_STATUS_KEY],
//         sellerId: map['seller_id'],
//         buyerId: map['buyer_id'],
//         orderStatus: map[ORDER_STATUS_KEY],
//         quantity: map['quantity']);
//   }

//   @override
//   Map<String, dynamic> toMap() {
//     final map = <String, dynamic>{
//       PRODUCT_UID_KEY: productUid,
//       ORDER_DATE_KEY: orderDate,
//       PAYMENT_STATUS_KEY: paymentStatus,
//       'seller_id': sellerId,
//       'buyer_id': buyerId,
//       ORDER_STATUS_KEY: orderStatus,
//       'quantity': quantity,
//     };

//     if (sellerId != null) map['seller_id'] = sellerId;
//     if (sellerId != null) map['buyer_id'] = buyerId;

//     return map;
//   }

//   @override
//   Map<String, dynamic> toUpdateMap() {
//     final map = <String, dynamic>{};
//     if (productUid != null) map[PRODUCT_UID_KEY] = productUid;
//     if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
//     if (paymentStatus != null) map[PAYMENT_STATUS_KEY] = paymentStatus;
//     if (buyerId != null) map["buyer_id"] = buyerId;
//     if (sellerId != null) map["seller_id"] = sellerId;
//     if (orderStatus != null) map[ORDER_STATUS_KEY] = orderStatus;
//     if (quantity != null) map['quantity'] = quantity;
//     return map;
//   }
// }
