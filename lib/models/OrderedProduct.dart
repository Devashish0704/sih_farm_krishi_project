import 'Model.dart';

class OrderedProduct extends Model {
  static const String PRODUCT_UID_KEY = "product_uid";
  static const String ORDER_DATE_KEY = "order_date";
  static const String PAYMENT_STATUS_KEY = "payment_status";

  String? productUid;
  String? orderDate;
  String? paymentStatus;
  String? sellerId;
  String? buyerId;

  OrderedProduct(String id,
      {this.productUid,
      this.orderDate,
      this.paymentStatus = "NA",
      this.sellerId,
      this.buyerId})
      : super(id);

  factory OrderedProduct.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderedProduct(id!,
        productUid: map[PRODUCT_UID_KEY],
        orderDate: map[ORDER_DATE_KEY],
        paymentStatus: map[PAYMENT_STATUS_KEY],
        sellerId: map['seller_id'],
        buyerId: map['buyer_id']);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      PRODUCT_UID_KEY: productUid,
      ORDER_DATE_KEY: orderDate,
      PAYMENT_STATUS_KEY: paymentStatus,
      'seller_id': sellerId,
      'buyer_id': buyerId,
    };

    if (sellerId != null) map['seller_id'] = sellerId;
    if (sellerId != null) map['buyer_id'] = buyerId;
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
    return map;
  }
}
