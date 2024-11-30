class Crop {
  final String id;
  final String state;
  final String apmc;
  final String commodity;
  final String minPrice;
  final String modalPrice;
  final String maxPrice;
  final String commodityArrivals;
  final String commodityTraded;
  final String createdAt;
  final String commodityUom;

  Crop({
    required this.id,
    required this.state,
    required this.apmc,
    required this.commodity,
    required this.minPrice,
    required this.modalPrice,
    required this.maxPrice,
    required this.commodityArrivals,
    required this.commodityTraded,
    required this.createdAt,
    required this.commodityUom,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'].toString(),
      state: json['state'] ?? '',
      apmc: json['apmc'] ?? '',
      commodity: json['commodity'] ?? '',
      minPrice: json['min_price']?.toString() ?? '',
      modalPrice: json['modal_price']?.toString() ?? '',
      maxPrice: json['max_price']?.toString() ?? '',
      commodityArrivals: json['commodity_arrivals']?.toString() ?? '',
      commodityTraded: json['commodity_traded']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      commodityUom: json['Commodity_Uom'] ?? '',
    );
  }
}
