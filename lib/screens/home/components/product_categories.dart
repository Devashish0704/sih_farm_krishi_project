// lib/screens/home/components/product_categories.dart
import 'package:e_commerce_app_flutter/models/Product.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String PRODUCT_TYPE_KEY = "product_type";

final List<Map<String, dynamic>> productCategories = [
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Cereals",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Fruits",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Pulses",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Vegetables",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Waste",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Others",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
];
