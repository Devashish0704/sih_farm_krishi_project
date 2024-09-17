import 'package:flutter/material.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';

enum ImageType {
  local,
  network,
}

class CustomImage {
  final ImageType imgType;
  final String path;

  CustomImage({this.imgType = ImageType.local, required this.path});

  @override
  String toString() {
    return "Instance of Custom Image: {imgType: $imgType, path: $path}";
  }
}

class ProductDetails extends ChangeNotifier {
  List<CustomImage> _selectedImages = [];
  ProductType? _productType;
  List<String> _searchTags = [];

  List<CustomImage> get selectedImages => _selectedImages;

  set initialSelectedImages(List<CustomImage> images) {
    _selectedImages = images;
  }

  set selectedImages(List<CustomImage> images) {
    _selectedImages = images;
    notifyListeners();
  }

  void setSelectedImageAtIndex(CustomImage image, int index) {
    if (index < _selectedImages.length) {
      _selectedImages[index] = image;
      notifyListeners();
    }
  }

  void addNewSelectedImage(CustomImage image) {
    print(image);
    _selectedImages.add(image);
    notifyListeners();
  }

  ProductType? get productType => _productType;

  set initialProductType(ProductType? type) {
    _productType = type;
  }

  set productType(ProductType? type) {
    _productType = type;
    notifyListeners();
  }

  List<String> get searchTags => _searchTags;

  set searchTags(List<String> tags) {
    _searchTags = tags;
    print("set $tags");
    notifyListeners();
  }

  set initSearchTags(List<String> tags) {
    _searchTags = tags;
  }

  void addSearchTag(String tag) {
    print("add $tag");
    _searchTags.add(tag);
    notifyListeners();
  }

  void removeSearchTag({int? index}) {
    if (index == null) {
      if (_searchTags.isNotEmpty) {
        _searchTags.removeLast();
      }
    } else if (index >= 0 && index < _searchTags.length) {
      _searchTags.removeAt(index);
    }
    notifyListeners();
  }
}
