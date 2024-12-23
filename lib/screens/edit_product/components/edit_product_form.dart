import 'dart:io';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/sample.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';

class ProductUploadForm extends StatefulWidget {
  final Product? product;

  const ProductUploadForm({Key? key, this.product}) : super(key: key);
  @override
  _ProductUploadFormState createState() => _ProductUploadFormState();
}

class _ProductUploadFormState extends State<ProductUploadForm> {
  // Step tracking
  int _currentStep = 0;

  // Step 1: Product Type Selection
  ProductType? _selectedProductType;

  // Step 2: Specific Category Selection
  String? _selectedCategory;

  // Step 3: Specific Product Selection
  String? _selectedProduct;

  // Step 4: Product Variety Selection
  String? _selectedVariety;

  // Step 5: Seed Company Selection
  String? _selectedSeedCompany;

  // Step 6: Harvest Date
  DateTime? _harvestDate;

  // Step 7: Grade and Organic Certification
  String? _selectedGrade;
  bool _isOrganic = false;
  List<File> _certificationImages = [];

  // Step 8: Order and Pricing Details
  int? _minimumOrderQuantity;

  int? _quantity;
  // String? _quantityUnit;
  bool _isPriceNegotiable = false;
  bool _isDeliveryAvailable = false;

  // Step 9: Product Images
  List<File> _productImages = [];
  List<String> _productImagesURLS = [];
  List<String> _certificateImagesURL = [];

  // Position? _position;

  double? _predictedPrice;
  double? _price;
  String? _rating;

  TextEditingController _priceController = TextEditingController();

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedProductType != null;
      case 1:
        return _selectedCategory != null;
      case 2:
        return _selectedProduct != null;
      case 3:
        return _selectedVariety != null;
      case 4:
        return _selectedSeedCompany != null;
      case 5:
        return _harvestDate != null;
      case 6:
        return _selectedGrade != null;
      case 7:
        return _minimumOrderQuantity != null;
      // return _minimumOrderQuantity != null && _price != null;
      case 8:
        return _productImages.isNotEmpty;
      // case 9:
      //   return true; // Review step always valid
      default:
        return true;
    }
  }

  // Helper method to build review sections
  Widget _buildReviewSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title + ':',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _uploadCertificationImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _certificationImages =
          pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  void _uploadProductImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _productImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
        imageFile,
        ProductDatabaseHelper().getPathForProductImage(fileName, 0),
      );

      String? downloadUrl = await showDialog(
        context: context,
        builder: (context) => AsyncProgressDialog(
          imgUploadFuture,
          message: Text("Uploading Image Details"),
        ),
      );

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
      return null;
    }
  }

  String _getRating() {
    try {
      return "8.5";
    } catch (e) {
      print(e);
      return "0.0"; // Default value in case of an error
    }
  }

  double _getPredictedPossiblePrice() {
    try {
      return 3500.0;
    } catch (e) {
      print(e);
      return 0.0; // Default value in case of an error
    }
  }

  void _submitProduct(
      double predictedPrice, double price, String rating) async {
    try {
      //step 1 upload product image
      while (_productImages.isNotEmpty) {
        final imageFile = _productImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _productImagesURLS.add(downloadUrl);
        }
      }

      //step 2 upload certification image
      while (_certificationImages.isNotEmpty) {
        final imageFile = _certificationImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _certificateImagesURL.add(downloadUrl);
        }
      }

      //step 3 submit product

      final product = Product(
        widget.product?.id ?? '',
        name: "${_selectedVariety}",
        category: _selectedCategory,
        variant: _selectedVariety,
        price: double.parse(price.toString()),
        predictivePrice: double.parse(predictedPrice.toString()),
        pointRating: double.parse(rating),
        rating: widget.product?.rating ?? 0,

        seed_company: _selectedSeedCompany,
        quantity: int.parse(_quantity.toString()),
        quantityName: "QN",
        //  phoneNumber: _phoneNumberController.text,
        position: await Geolocator.getCurrentPosition(),
        images: _productImagesURLS,
        productType: _selectedProductType,

        // New fields added
        harvestDate: _harvestDate,
        isOrganic: _isOrganic,

        certificationImages: _certificateImagesURL,
        //  storageMethod: _storageMethodController.text,
        grade: _selectedGrade,
        minimumOrderQuantity: int.tryParse(_minimumOrderQuantity.toString()),
        isPriceNegotiable: _isPriceNegotiable,
        isDeliveryAvailable: _isDeliveryAvailable,
      );
      print(product.productType);
      print(product);

      if (widget.product == null) {
        await ProductDatabaseHelper().addUsersProduct(product);
      } else {
        await ProductDatabaseHelper().updateUsersProduct(product);
      }
      print('Product submitted successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
    // Here you would implement your product submission logic
    // This would involve creating a Product object and saving it to your database
  }

  // Add a method to get a formatted string for various fields
  String _getFormattedValue(dynamic value) {
    if (value == null) return 'Not Selected';
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload New Product'),
        backgroundColor: Colors.teal,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _currentStep > 0 ? _previousStep : null,
        steps: [
          // Step 1: Product Type
          Step(
            title: Text('Select Product Type'),
            content: DropdownButtonFormField<ProductType>(
              value: _selectedProductType,
              items: ProductType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(EnumToString.convertToString(type)),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedProductType = value;
                print(value);
                _selectedCategory = null;
                _selectedProduct = null;
                _selectedVariety = null;
              }),
              decoration: InputDecoration(
                labelText: 'Product Type',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Step 2: Category Selection
          Step(
            title: Text('Select Category'),
            content: _selectedProductType != null
                ? DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: productCategories[_selectedProductType]!
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategory = value;
                      _selectedProduct = null;
                      _selectedVariety = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a product type first'),
          ),

          // Step 3: Product Selection
          Step(
            title: Text('Select Product'),
            content: _selectedCategory != null
                ? DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    items: categoryProducts[_selectedCategory]!
                        .map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedProduct = value;
                      _selectedVariety = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a category first'),
          ),

          // Step 4: Variety Selection
          Step(
            title: Text('Select Variety'),
            content: _selectedProduct != null
                ? DropdownButtonFormField<String>(
                    value: _selectedVariety,
                    items: productVarieties[_selectedProduct]!
                        .map((variety) => DropdownMenuItem(
                              value: variety,
                              child: Text(variety),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedVariety = value;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Variety',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a product first'),
          ),

          // Step 5: Seed Company Selection
          Step(
            title: Text('Select Seed Company'),
            content: DropdownButtonFormField<String>(
              value: _selectedSeedCompany,
              items: seedCompanies
                  .map((company) => DropdownMenuItem(
                        value: company,
                        child: Text(company),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedSeedCompany = value;
              }),
              decoration: InputDecoration(
                labelText: 'Seed Company',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Step 6: Harvest Date
          Step(
            title: Text('Select Harvest Date'),
            content: ListTile(
              title: Text('Harvest Date'),
              subtitle: Text(_harvestDate == null
                  ? 'Select Harvest Date'
                  : '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _harvestDate = pickedDate;
                  });
                }
              },
            ),
          ),

          // Step 7: Grade and Organic Certification
          Step(
            title: Text('Grade and Certification'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  items: grades
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedGrade = value;
                  }),
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  title: Text('Is Organic?'),
                  value: _isOrganic,
                  onChanged: (bool value) {
                    setState(() {
                      _isOrganic = value;
                    });
                  },
                ),
                if (_isOrganic)
                  ElevatedButton(
                    onPressed: _uploadCertificationImages,
                    child: Text('Upload Organic Certification'),
                  ),
              ],
            ),
          ),

          // Step 8: Order and Pricing Details
          Step(
            title: Text('Order and Pricing'),
            content: Column(
              children: [
                //
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Total Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _quantity = int.tryParse(value);
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Minimum Order Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minimumOrderQuantity = int.tryParse(value);
                  },
                ),
                //  SizedBox(height: 16),
                // TextFormField(
                //   decoration: InputDecoration(
                //     labelText: 'Price per Unit',
                //     prefixText: '₹ ',
                //     border: OutlineInputBorder(),
                //   ),
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                //   onChanged: (value) {
                //     _price = double.tryParse(value);
                //   },
                // ),

                // Row(
                //   children: [
                //     Expanded(
                //       flex: 2,
                //       child:
                //     ),
                //     SizedBox(width: 16),
                //     Expanded(
                //       child: DropdownButtonFormField<String>(
                //         value: _quantityUnit,
                //         items: quantityUnits
                //             .map((unit) => DropdownMenuItem(
                //                   value: unit,
                //                   child: Text(unit),
                //                 ))
                //             .toList(),
                //         onChanged: (value) => setState(() {
                //           _quantityUnit = value;
                //         }),
                //         decoration: InputDecoration(
                //           labelText: 'Unit',
                //           border: OutlineInputBorder(),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 2,
                ),
                // SwitchListTile(
                //   title: Text('Is Price Negotiable?'),
                //   value: _isPriceNegotaible,
                //   onChanged: (bool value) {
                //     setState(() {
                //       _isPriceNegotaible = value;
                //     });
                //   },
                // ),
                SizedBox(
                  height: 2,
                ),
                SwitchListTile(
                  title: Text('Is Deliverable?'),
                  value: _isDeliveryAvailable,
                  onChanged: (bool value) {
                    setState(() {
                      _isDeliveryAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Step 9: Product Images
          Step(
            title: Text('Upload Product Images'),
            content: Column(
              children: [
                ElevatedButton(
                  onPressed: _uploadProductImages,
                  child: Text('Upload Product Images'),
                ),
                SizedBox(height: 16),
                _productImages.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _productImages.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            _productImages[index],
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Text('No images selected'),
              ],
            ),
          ),
          //   // New Step 9: Review Details
          //   Step(
          //     title: Text('Review Details'),
          //     content: SingleChildScrollView(
          //       child: reviewCard(context),
          //     ),
          //   ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text('Back'),
                ),
              ElevatedButton(
                onPressed: _currentStep < 8
                    ? details.onStepContinue
                    : () => _showReviewBottomSheet(context),
                child: Text(_currentStep < 8 ? 'Next' : 'Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget reviewCard(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewSection(
                'Product Type', _getFormattedValue(_selectedProductType)),
            _buildReviewSection(
                'Category', _getFormattedValue(_selectedCategory)),
            _buildReviewSection(
                'Product', _getFormattedValue(_selectedProduct)),
            _buildReviewSection(
                'Variety', _getFormattedValue(_selectedVariety)),
            _buildReviewSection(
                'Seed Company', _getFormattedValue(_selectedSeedCompany)),
            _buildReviewSection(
                'Harvest Date', _getFormattedValue(_harvestDate)),
            _buildReviewSection('Grade', _getFormattedValue(_selectedGrade)),
            _buildReviewSection('Organic', _getFormattedValue(_isOrganic)),
            _buildReviewSection('Minimum Order Quantity',
                _getFormattedValue(_minimumOrderQuantity)),
            // _buildReviewSection(
            //     'Price',
            //     _price != null
            //         ? '₹ ${_price!.toStringAsFixed(2)}'
            //         : 'Not Set'),
            // _buildReviewSection('Quantity',
            //     '${_getFormattedValue(_quantity)} ${_getFormattedValue(_quantityUnit)}'),
            // _buildReviewSection(
            //     'Price Negotiable', _getFormattedValue(_isPriceNegotaible)),
            _buildReviewSection(
                'Delivery Available', _getFormattedValue(_isDeliveryAvailable)),

            // Product Images Preview
            Text('Product Images:',
                style: Theme.of(context).textTheme.titleMedium),
            _productImages.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _productImages.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        _productImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Text('No images selected'),
          ],
        ),
      ),
    );
  }

  // Method to show review bottom sheet
  void _showReviewBottomSheet(BuildContext context) {
    bool isReviewStep = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  // Dynamic Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isReviewStep
                          ? 'Review Your Product Details'
                          : 'Confirm Your Pricing',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Conditional Content
                  isReviewStep
                      ? reviewCard(context)
                      : _buildPricingContent(context),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (!isReviewStep)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setModalState(() {
                                  isReviewStep = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: Text('Back'),
                            ),
                          ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isReviewStep) {
                                // Move to pricing step
                                setModalState(() {
                                  isReviewStep = false;
                                });
                              } else {
                                // Final submission
                                _confirmAndSubmit(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: Text(isReviewStep
                                ? 'Next: Pricing'
                                : 'Confirm and Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build Pricing Content
  Widget _buildPricingContent(BuildContext context) {
    _predictedPrice = _getPredictedPossiblePrice();
    _rating = _getRating();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Predicted Price Card
          Card(
            elevation: 4,
            color: Colors.teal[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Your Rating is :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _rating != null ? _rating! : 'rating Not Available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  Text(
                    'Predicted Price',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _predictedPrice != null
                        ? '₹ ${_predictedPrice!.toStringAsFixed(2)}'
                        : 'Price Not Available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This price is based on market trends and your product details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.teal[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Custom Price Input
          Text(
            'Adjust Price (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Enter Custom Price',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
              helperText: 'Leave blank to use predicted price',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 10),

          SwitchListTile(
            title: Text('Is Price Negotiable?'),
            value: _isPriceNegotiable,
            onChanged: (bool value) {
              print(value);
              setState(() {
                _isPriceNegotiable = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Method to handle final submission
  void _confirmAndSubmit(BuildContext context) {
    // Use custom price if provided, otherwise use original price
    final finalPrice = _priceController.text.isNotEmpty
        ? double.tryParse(_priceController.text)
        : _predictedPrice;

    // Validate final price
    if (finalPrice == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid price')));
      return;
    }

    // Update price with final value
    setState(() {
      _price = finalPrice;
    });

    // Close bottom sheet
    Navigator.of(context).pop();

    // Proceed with product submission
    _submitProduct(_predictedPrice!, _price!, _rating!);
  }
}

// import 'dart:io';
// import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// import 'package:e_commerce_app_flutter/screens/edit_product/provider_models/ProductDetails.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:enum_to_string/enum_to_string.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';

// class ProductUploadForm extends StatefulWidget {
//   final Product? product;

//   ProductUploadForm({this.product});

//   @override
//   _ProductUploadFormState createState() => _ProductUploadFormState();
// }

// class _ProductUploadFormState extends State<ProductUploadForm> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for all possible text fields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _variantController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _highlightsController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _seedCompanyController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _quantityNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _storageMethodController =
//       TextEditingController();
//   final TextEditingController _gradeController = TextEditingController();
//   final TextEditingController _minimumOrderQuantityController =
//       TextEditingController();

//   // Additional fields
//   ProductType? _selectedProductType;
//   DateTime? _harvestDate;
//   bool _isOrganic = false;
//   bool _isPriceNegotiable = false;
//   bool _isDeliveryAvailable = false;

//   List<CustomImage> _selectedImages = [];
//   List<CustomImage> _certificationImages = [];
//   Position? _position;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.product != null) {
//       // Populate all controllers with existing product data
//       _nameController.text = widget.product!.name ?? '';
//       _variantController.text = widget.product!.variant ?? '';
//       _priceController.text = widget.product!.price?.toString() ?? '';
//       _highlightsController.text = widget.product!.highlights ?? '';
//       _descriptionController.text = widget.product!.description ?? '';
//       _seedCompanyController.text = widget.product!.seed_company ?? '';
//       _quantityController.text = widget.product!.quantity?.toString() ?? '';
//       _quantityNameController.text = widget.product!.quantityName ?? '';
//       _phoneNumberController.text = widget.product!.phoneNumber ?? '';

//       _storageMethodController.text = widget.product!.storageMethod ?? '';
//       _gradeController.text = widget.product!.grade ?? '';
//       _minimumOrderQuantityController.text =
//           widget.product!.minimumOrderQuantity?.toString() ?? '';

//       _selectedProductType = widget.product!.productType;
//       _harvestDate = widget.product!.harvestDate;
//       _isOrganic = widget.product!.isOrganic ?? false;
//       _isPriceNegotiable = widget.product!.isPriceNegotiable ?? false;
//       _isDeliveryAvailable = widget.product!.isDeliveryAvailable ?? false;

//       _selectedImages = widget.product!.images
//               ?.map((url) => CustomImage(imgType: ImageType.network, path: url))
//               .toList() ??
//           [];
//       _certificationImages = widget.product!.certificationImages
//               ?.map((url) => CustomImage(imgType: ImageType.network, path: url))
//               .toList() ??
//           [];
//       _position = widget.product!.position;
//     }
//   }

//   // Image upload methods remain the same as in the previous implementation
//   Future<void> _addImageButtonCallback(
//       {int? index, bool isCertification = false}) async {
//     final imagePicker = ImagePicker();
//     final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       File imageFile = File(pickedFile.path);
//       String? downloadUrl = await _uploadImage(imageFile);

//       if (downloadUrl != null) {
//         setState(() {
//           if (isCertification) {
//             if (index != null && index < _certificationImages.length) {
//               _certificationImages[index] =
//                   CustomImage(imgType: ImageType.network, path: downloadUrl);
//             } else {
//               _certificationImages.add(
//                   CustomImage(imgType: ImageType.network, path: downloadUrl));
//             }
//           } else {
//             if (index != null && index < _selectedImages.length) {
//               _selectedImages[index] =
//                   CustomImage(imgType: ImageType.network, path: downloadUrl);
//             } else {
//               _selectedImages.add(
//                   CustomImage(imgType: ImageType.network, path: downloadUrl));
//             }
//           }
//         });
//       }
//     }
//   }

//   Future<String?> _uploadImage(File imageFile) async {
//     try {
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
//         imageFile,
//         ProductDatabaseHelper().getPathForProductImage(fileName, 0),
//       );

//       String? downloadUrl = await showDialog(
//         context: context,
//         builder: (context) => AsyncProgressDialog(
//           imgUploadFuture,
//           message: Text("Fetching Image Details"),
//         ),
//       );

//       return downloadUrl;
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
//       return null;
//     }
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final product = Product(
//           widget.product?.id ?? '',
//           name: _nameController.text,
//           variant: _variantController.text,
//           price: double.parse(_priceController.text),
//           rating: widget.product?.rating ?? 0,
//           highlights: _highlightsController.text,
//           description: _descriptionController.text,
//           seed_company: _seedCompanyController.text,
//           quantity: int.parse(_quantityController.text),
//           quantityName: _quantityNameController.text,
//           phoneNumber: _phoneNumberController.text,
//           position: _position ?? await Geolocator.getCurrentPosition(),
//           images: _selectedImages.map((img) => img.path).toList(),
//           productType: _selectedProductType,

//           // New fields added
//           harvestDate: _harvestDate,
//           isOrganic: _isOrganic,

//           certificationImages:
//               _certificationImages.map((img) => img.path).toList(),
//           storageMethod: _storageMethodController.text,
//           grade: _gradeController.text,
//           minimumOrderQuantity:
//               int.tryParse(_minimumOrderQuantityController.text),
//           isPriceNegotiable: _isPriceNegotiable,
//           isDeliveryAvailable: _isDeliveryAvailable,
//         );
//         print(product);

//         if (widget.product == null) {
//           await ProductDatabaseHelper().addUsersProduct(product);
//         } else {
//           await ProductDatabaseHelper().updateUsersProduct(product);
//         }

//         Navigator.of(context).pop();
//       } catch (e) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Error saving product: $e")));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Existing text fields...
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter a title' : null,
//               ),
//               SizedBox(height: 16),

//               TextFormField(
//                 controller: _storageMethodController,
//                 decoration: InputDecoration(
//                   labelText: 'Storage Method',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               SizedBox(height: 16),

//               TextFormField(
//                 controller: _gradeController,
//                 decoration: InputDecoration(
//                   labelText: 'Grade',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               SizedBox(height: 16),

//               // Checkbox for additional boolean fields
//               CheckboxListTile(
//                 title: Text('Is Organic'),
//                 value: _isOrganic,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _isOrganic = value ?? false;
//                   });
//                 },
//               ),
//               CheckboxListTile(
//                 title: Text('Price Negotiable'),
//                 value: _isPriceNegotiable,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _isPriceNegotiable = value ?? false;
//                   });
//                 },
//               ),
//               CheckboxListTile(
//                 title: Text('Delivery Available'),
//                 value: _isDeliveryAvailable,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _isDeliveryAvailable = value ?? false;
//                   });
//                 },
//               ),

//               // Harvest Date Picker
//               ListTile(
//                 title: Text('Harvest Date'),
//                 subtitle: Text(_harvestDate == null
//                     ? 'Select Harvest Date'
//                     : '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'),
//                 onTap: () async {
//                   final pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: _harvestDate ?? DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime.now(),
//                   );
//                   if (pickedDate != null) {
//                     setState(() {
//                       _harvestDate = pickedDate;
//                     });
//                   }
//                 },
//               ),

//               // Certification Images
//               Text('Certification Images',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Container(
//                 height: 120,
//                 width: MediaQuery.of(context).size.width,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     ..._certificationImages
//                         .asMap()
//                         .entries
//                         .map((entry) => Padding(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: GestureDetector(
//                                 onTap: () => _addImageButtonCallback(
//                                     index: entry.key, isCertification: true),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(entry.value.path,
//                                       width: 100,
//                                       height: 100,
//                                       fit: BoxFit.cover),
//                                 ),
//                               ),
//                             )),
//                     if (_certificationImages.length < 3)
//                       GestureDetector(
//                         onTap: () =>
//                             _addImageButtonCallback(isCertification: true),
//                         child: Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(Icons.add_photo_alternate,
//                               size: 40, color: Colors.grey[600]),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               // Rest of the existing fields...

//               TextFormField(
//                 controller: _variantController,
//                 decoration: InputDecoration(
//                   labelText: 'Variant',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text('Product Images',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Container(
//                 height: 120,
//                 width: MediaQuery.of(context).size.width,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     ..._selectedImages.asMap().entries.map((entry) => Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: GestureDetector(
//                             onTap: () =>
//                                 _addImageButtonCallback(index: entry.key),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(entry.value.path,
//                                   width: 100, height: 100, fit: BoxFit.cover),
//                             ),
//                           ),
//                         )),
//                     if (_selectedImages.length < 3)
//                       GestureDetector(
//                         onTap: _addImageButtonCallback,
//                         child: Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(Icons.add_photo_alternate,
//                               size: 40, color: Colors.grey[600]),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Text(cropName,
//               //     style:
//               //         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               // SizedBox(height: 10),
//               // Text('Mandi Price: of ₹${mandiPrice.toString()}/kg',
//               //     style:
//               //         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: InputDecoration(
//                   labelText: 'Price',
//                   prefixText: '₹ ',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter a price' : null,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _highlightsController,
//                 decoration: InputDecoration(
//                   labelText: 'Highlights',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//                 maxLines: 3,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//                 maxLines: 5,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _seedCompanyController,
//                 decoration: InputDecoration(
//                   labelText: 'Seed Company',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               SizedBox(height: 16),
//               Container(
//                 height: 120,
//                 width: MediaQuery.of(context).size.width,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _quantityController,
//                         decoration: InputDecoration(
//                           labelText: 'Quantity',
//                           border: OutlineInputBorder(),
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                         ),
//                         keyboardType: TextInputType.number,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _quantityNameController,
//                         decoration: InputDecoration(
//                           labelText: 'Quantity Name',
//                           border: OutlineInputBorder(),
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<ProductType>(
//                 value: _selectedProductType,
//                 items: ProductType.values
//                     .map((type) => DropdownMenuItem(
//                           value: type,
//                           child: Text(EnumToString.convertToString(type)),
//                         ))
//                     .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedProductType = value),
//                 decoration: InputDecoration(
//                   labelText: 'Product Type',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitForm,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     child: Text('Save Product', style: TextStyle(fontSize: 18)),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
