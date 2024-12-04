// lib/screens/home/components/product_categories.dart
import 'package:e_commerce_app_flutter/models/Product.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String PRODUCT_TYPE_KEY = "product_type";

final List<Map<String, dynamic>> productCategories = [
  <String, dynamic>{
    ICON_KEY: "assets/icons/cereal.svg",
    TITLE_KEY: "Cereals",
    PRODUCT_TYPE_KEY: "Cereals",
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/fruits.svg",
    TITLE_KEY: "Fruits",
    // PRODUCT_TYPE_KEY: "Fruits",
    PRODUCT_TYPE_KEY: "Fruits",
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/carrot.svg",
    TITLE_KEY: "Vegetables",
    //  PRODUCT_TYPE_KEY: ProductType.freshProduce,
    PRODUCT_TYPE_KEY: "Vegetables",
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/wheat.svg",
    TITLE_KEY: "Pulses",
    PRODUCT_TYPE_KEY: "Pulses",
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/milk.svg",
    TITLE_KEY: "Milk",
    PRODUCT_TYPE_KEY: ProductType.dairyProducts,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/chease.svg",
    TITLE_KEY: "Cheese",
    PRODUCT_TYPE_KEY: ProductType.spicesAndHerbs,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/chicken.svg",
    TITLE_KEY: "Chicken",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/fish.svg",
    TITLE_KEY: "Fish",
    PRODUCT_TYPE_KEY: ProductType.animalFeed,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/honey.svg",
    TITLE_KEY: "Honey",
    PRODUCT_TYPE_KEY: ProductType.organicProducts,
  },
  <String, dynamic>{
    ICON_KEY: "assets/icons/Others.svg",
    TITLE_KEY: "Others",
    PRODUCT_TYPE_KEY: ProductType.miscellaneous,
  },
];
