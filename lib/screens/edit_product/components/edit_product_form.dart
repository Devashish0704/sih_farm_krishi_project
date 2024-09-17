import 'dart:io';
import 'dart:math';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/screens/edit_product/provider_models/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';

class ProductUploadForm extends StatefulWidget {
  final Product? product;

  ProductUploadForm({this.product});

  @override
  _ProductUploadFormState createState() => _ProductUploadFormState();
}

class _ProductUploadFormState extends State<ProductUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _variantController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _highlightsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _seedCompanyController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _quantityNameController = TextEditingController();

  ProductType? _selectedProductType;
  List<String> _searchTags = [];
  List<CustomImage> _selectedImages = [];
  Position? _position;

  List<double> randomIncrements = [0, 0, 0];
  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _titleController.text = widget.product!.title ?? '';
      _variantController.text = widget.product!.variant ?? '';
      _priceController.text = widget.product!.price?.toString() ?? '';
      _highlightsController.text = widget.product!.highlights ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _seedCompanyController.text = widget.product!.seed_company ?? '';
      _quantityController.text = widget.product!.quantity?.toString() ?? '';
      _quantityNameController.text = widget.product!.quantityName ?? '';
      _selectedProductType = widget.product!.productType;

      _selectedImages = widget.product!.images
              ?.map((url) => CustomImage(imgType: ImageType.network, path: url))
              .toList() ??
          [];
      _position = widget.product!.position;
    }
  }

  Future<void> _addImageButtonCallback({int? index}) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? downloadUrl = await _uploadImage(imageFile);

      if (downloadUrl != null) {
        setState(() {
          if (index != null && index < _selectedImages.length) {
            _selectedImages[index] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            _selectedImages.add(
                CustomImage(imgType: ImageType.network, path: downloadUrl));
          }
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
        imageFile,
        ProductDatabaseHelper().getPathForProductImage(fileName, 0),
      );

      DocumentSnapshot vegetable =
          await FirebaseFirestore.instance.collection('fake').doc('crop').get();
      print(vegetable["name"]);
      cropName = vegetable["name"];
      if (cropName == "Potato") {
        mandiPrice = 50;
      } else if (cropName == "Tomato") {
        mandiPrice = 60;
      }
      _generateRandomIncrements();
      String? downloadUrl = await showDialog(
        context: context,
        builder: (context) => AsyncProgressDialog(
          imgUploadFuture,
          message: Text("Fetching Image Details"),
        ),
      );

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
      return null;
    }
  }

  String cropName = "";
  int mandiPrice = 0;
  void _generateRandomIncrements() {
    final Random random = Random();
    final Set<double> increments = {};

    // Generate 3 unique random increments within the range of 1 to 30
    while (increments.length < 3) {
      double increment =
          random.nextInt(30) + 1; // Random increment from 1 to 30
      increments.add(increment);
    }

    // Sort the increments and assign them to the randomIncrements list
    randomIncrements = increments.toList()..sort();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          widget.product?.id ?? '',
          title: _titleController.text,
          variant: _variantController.text,
          price: double.parse(_priceController.text),
          rating: widget.product?.rating ?? 0,
          highlights: _highlightsController.text,
          description: _descriptionController.text,
          seed_company: _seedCompanyController.text,
          quantity: int.parse(_quantityController.text),
          quantityName: _quantityNameController.text,
          position: _position ?? await Geolocator.getCurrentPosition(),
          images: _selectedImages.map((img) => img.path).toList(),
          productType: _selectedProductType,
        );

        if (cropName == "not recognisable") {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Image is not recognisable")));
          Navigator.of(context).pop();
        }

        if (widget.product == null) {
          await ProductDatabaseHelper().addUsersProduct(product);
        } else {
          await ProductDatabaseHelper().updateUsersProduct(product);
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error saving product: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _variantController,
                  decoration: InputDecoration(
                    labelText: 'Variant',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                Text('Product Images',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._selectedImages.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  _addImageButtonCallback(index: entry.key),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(entry.value.path,
                                    width: 100, height: 100, fit: BoxFit.cover),
                              ),
                            ),
                          )),
                      if (_selectedImages.length < 3)
                        GestureDetector(
                          onTap: _addImageButtonCallback,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(cropName,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Mandi Price: of ₹${mandiPrice.toString()}/kg',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  width: 300,
                  child: Wrap(
                    spacing: 10,
                    children: randomIncrements.map((increment) {
                      return ElevatedButton(
                        onPressed: () => _priceController.text =
                            (mandiPrice + increment).toString(),
                        child: Text((mandiPrice + increment).toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Container(
                //   // height: 200,
                //   width: 300,
                //   child: Wrap(
                //     spacing: 10,
                //     children: [
                //       ElevatedButton(
                //         onPressed: () =>
                //             _priceController.text = (mandiPrice + 5).toString(),
                //         child: Text((mandiPrice + 5).toString()),
                //         style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.green),
                //       ),
                //       ElevatedButton(
                //         onPressed: () => _priceController.text =
                //             (mandiPrice + 10).toString(),
                //         child: Text((mandiPrice + 10).toString()),
                //         style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.green),
                //       ),
                //       ElevatedButton(
                //         onPressed: () => _priceController.text =
                //             (mandiPrice + 15).toString(),
                //         child: Text((mandiPrice + 15).toString()),
                //         style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.green),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a price' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _highlightsController,
                  decoration: InputDecoration(
                    labelText: 'Highlights',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _seedCompanyController,
                  decoration: InputDecoration(
                    labelText: 'Seed Company',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityNameController,
                          decoration: InputDecoration(
                            labelText: 'Quantity Name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<ProductType>(
                  value: _selectedProductType,
                  items: ProductType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(EnumToString.convertToString(type)),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedProductType = value),
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child:
                          Text('Save Product', style: TextStyle(fontSize: 18)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
// import 'package:e_commerce_app_flutter/components/default_button.dart';
// import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
// import 'package:e_commerce_app_flutter/exceptions/local_files_handling/local_file_handling_exception.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:e_commerce_app_flutter/screens/edit_product/provider_models/ProductDetails.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';
// import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
// import 'package:enum_to_string/enum_to_string.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tags/flutter_tags.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';

// import '../../../constants.dart';
// import '../../../size_config.dart';

// class EditProductForm extends StatefulWidget {
//   final Product? product;
//   EditProductForm({
//     this.product,
//   });

//   @override
//   _EditProductFormState createState() => _EditProductFormState();
// }

// class _EditProductFormState extends State<EditProductForm> {
//   final _basicDetailsFormKey = GlobalKey<FormState>();
//   final _describeProductFormKey = GlobalKey<FormState>();
//   final _tagStateKey = GlobalKey<TagsState>();

//   final TextEditingController titleFieldController = TextEditingController();
//   final TextEditingController variantFieldController = TextEditingController();
//   final TextEditingController discountPriceFieldController =
//       TextEditingController();
//   final TextEditingController originalPriceFieldController =
//       TextEditingController();
//   final TextEditingController highlightsFieldController =
//       TextEditingController();
//   final TextEditingController desciptionFieldController =
//       TextEditingController();
//   final TextEditingController sellerFieldController = TextEditingController();

//   bool newProduct = true;
//   Product? product;

//   @override
//   void dispose() {
//     titleFieldController.dispose();
//     variantFieldController.dispose();
//     discountPriceFieldController.dispose();
//     originalPriceFieldController.dispose();
//     highlightsFieldController.dispose();
//     desciptionFieldController.dispose();
//     sellerFieldController.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (widget.product == null) {
//       product = Product("", position:  Position(
//         latitude: 0.0,
//         longitude: 0.0,
//         timestamp: DateTime.now(),
//         accuracy: 0.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       ),);
//       newProduct = true;
//     } else {
//       product = widget.product;
//       newProduct = false;
//       final productDetails =
//           Provider.of<ProductDetails>(context, listen: false);
//       productDetails.initialSelectedImages = widget.product!.images!
//           .map((e) => CustomImage(imgType: ImageType.network, path: e))
//           .toList();
//       productDetails.initialProductType = product!.productType;
//     //  productDetails.initSearchTags = product!.searchTags ?? [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final column = Column(
//       children: [
//         buildBasicDetailsTile(context),
//         SizedBox(height: getProportionateScreenHeight(10)),
//         buildDescribeProductTile(context),
//         SizedBox(height: getProportionateScreenHeight(10)),
//         buildUploadImagesTile(context),
//         SizedBox(height: getProportionateScreenHeight(20)),
//         buildProductTypeDropdown(),
//         SizedBox(height: getProportionateScreenHeight(20)),
//         buildProductSearchTagsTile(),
//         SizedBox(height: getProportionateScreenHeight(80)),
//         DefaultButton(
//             text: "Save Product",
//             press: () {
//               saveProductButtonCallback(context);
//             }),
//         SizedBox(height: getProportionateScreenHeight(10)),
//       ],
//     );
//     if (newProduct == false) {
//       titleFieldController.text = product!.title!;
//       variantFieldController.text = product!.variant!;
      
//       originalPriceFieldController.text = product!.price!.toString();
//       highlightsFieldController.text = product!.highlights!;
//       desciptionFieldController.text = product!.description!;
//       sellerFieldController.text = product!.seed_company!;
//     }
//     return column;
//   }

//   Widget buildProductSearchTags() {
//     return Consumer<ProductDetails>(
//       builder: (context, productDetails, child) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Input Field
//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Add search tag",
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: (String str) {
//                 if (str.isNotEmpty) {
//                   productDetails.addSearchTag(str.toLowerCase());
//                 }
//               },
//             ),
//             SizedBox(height: 16.0),
//             // Tags List
//             Wrap(
//               spacing: 8.0,
//               runSpacing: 4.0,
//               children: productDetails.searchTags.map((tag) {
//                 return ActionChip(
//                   label: Text(tag),
//                   backgroundColor: kPrimaryColor,
//                   labelStyle: TextStyle(color: Colors.white),
//                   onPressed: () {
//                     // Handle chip press (e.g., navigate to a tag-specific page)
//                   },

//                   // deleteIcon: Icon(Icons.close, color: Colors.white),
//                   // onDeleted: () {
//                   //   productDetails.removeSearchTag(tag);
//                   // },
//                 );
//               }).toList(),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   // Widget buildProductSearchTags() {
//   //   return Consumer<ProductDetails>(
//   //     builder: (context, productDetails, child) {
//   //       return Tags(
//   //         key: _tagStateKey,
//   //         horizontalScroll: true,
//   //         heightHorizontalScroll: getProportionateScreenHeight(80),
//   //         textField: TagsTextField(
//   //           lowerCase: true,
//   //           width: getProportionateScreenWidth(120),
//   //           constraintSuggestion: true,
//   //           hintText: "Add search tag",
//   //           keyboardType: TextInputType.name,
//   //           onChanged: (string) {
//   //             print(string);
//   //           },
//   //           onSubmitted: (String str) {
//   //             print(str);
//   //             productDetails.addSearchTag(str.toLowerCase());
//   //           },
//   //         ),
//   //         itemCount: productDetails.searchTags.length,
//   //         itemBuilder: (index) {
//   //           final item = productDetails.searchTags[index];
//   //           print(item);
//   //           return ItemTags(
//   //             index: index,
//   //             title: item,
//   //             active: true,
//   //             activeColor: kPrimaryColor,
//   //             padding: EdgeInsets.symmetric(
//   //               horizontal: 12,
//   //               vertical: 8,
//   //             ),
//   //             alignment: MainAxisAlignment.spaceBetween,
//   //             removeButton: ItemTagsRemoveButton(
//   //               backgroundColor: Colors.white,
//   //               color: kTextColor,
//   //               onRemoved: () {
//   //                 productDetails.removeSearchTag(index: index);
//   //                 return true;
//   //               },
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   Widget buildBasicDetailsTile(BuildContext context) {
//     return Form(
//       key: _basicDetailsFormKey,
//       child: ExpansionTile(
//         maintainState: true,
//         title: Text(
//           "Basic Details",
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         leading: Icon(
//           Icons.shop,
//         ),
//         childrenPadding:
//             EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
//         children: [
//           buildTitleField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//           buildVariantField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//           buildOriginalPriceField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//           buildDiscountPriceField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//           buildSellerField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//         ],
//       ),
//     );
//   }

//   bool validateBasicDetailsForm() {
//     if (_basicDetailsFormKey.currentState!.validate()) {
//       _basicDetailsFormKey.currentState!.save();
//       product!.title = titleFieldController.text;
//       product!.variant = variantFieldController.text;
//       product!.price = double.parse(originalPriceFieldController.text);
//       // product!.discountPrice = double.parse(discountPriceFieldController.text);
//       product!.seed_company = sellerFieldController.text;
//       return true;
//     }
//     return false;
//   }

//   Widget buildDescribeProductTile(BuildContext context) {
//     return Form(
//       key: _describeProductFormKey,
//       child: ExpansionTile(
//         maintainState: true,
//         title: Text(
//           "Describe Product",
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         leading: Icon(
//           Icons.description,
//         ),
//         childrenPadding:
//             EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
//         children: [
//           buildHighlightsField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//           buildDescriptionField(),
//           SizedBox(height: getProportionateScreenHeight(20)),
//         ],
//       ),
//     );
//   }

//   bool validateDescribeProductForm() {
//     if (_describeProductFormKey.currentState!.validate()) {
//       _describeProductFormKey.currentState!.save();
//       product!.highlights = highlightsFieldController.text;
//       product!.description = desciptionFieldController.text;
//       return true;
//     }
//     return false;
//   }

//   Widget buildProductTypeDropdown() {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 24,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         border: Border.all(color: kTextColor, width: 1),
//         borderRadius: BorderRadius.all(Radius.circular(28)),
//       ),
//       child: Consumer<ProductDetails>(
//         builder: (context, productDetails, child) {
//           return DropdownButton(
//             value: productDetails.productType,
//             items: ProductType.values
//                 .map(
//                   (e) => DropdownMenuItem(
//                     value: e,
//                     child: Text(
//                       EnumToString.convertToString(e),
//                     ),
//                   ),
//                 )
//                 .toList(),
//             hint: Text(
//               "Chose Product Type",
//             ),
//             style: TextStyle(
//               color: kTextColor,
//               fontSize: 16,
//             ),
//             onChanged: (value) {
//               productDetails.productType = value as ProductType;
//             },
//             elevation: 0,
//             underline: SizedBox(width: 0, height: 0),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildProductSearchTagsTile() {
//     return ExpansionTile(
//       title: Text(
//         "Search Tags",
//         style: Theme.of(context).textTheme.headlineSmall,
//       ),
//       leading: Icon(Icons.check_circle_sharp),
//       childrenPadding:
//           EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
//       children: [
//         Text("Your product will be searched for this Tags"),
//         SizedBox(height: getProportionateScreenHeight(15)),
//         buildProductSearchTags(),
//       ],
//     );
//   }

//   Widget buildUploadImagesTile(BuildContext context) {
//     return ExpansionTile(
//       title: Text(
//         "Upload Images",
//         style: Theme.of(context).textTheme.headlineSmall,
//       ),
//       leading: Icon(Icons.image),
//       childrenPadding:
//           EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: IconButton(
//               icon: Icon(
//                 Icons.add_a_photo,
//               ),
//               color: kTextColor,
//               onPressed: () {
//                 addImageButtonCallback();
//               }),
//         ),
//         Consumer<ProductDetails>(
//           builder: (context, productDetails, child) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ...List.generate(
//                   productDetails.selectedImages.length,
//                   (index) => SizedBox(
//                     width: 80,
//                     height: 80,
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           addImageButtonCallback(index: index);
//                         },
//                         child: productDetails.selectedImages[index].imgType ==
//                                 ImageType.local
//                             ? Image.memory(
//                                 File(productDetails.selectedImages[index].path)
//                                     .readAsBytesSync())
//                             : Image.network(
//                                 productDetails.selectedImages[index].path),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget buildTitleField() {
//     return TextFormField(
//       controller: titleFieldController,
//       keyboardType: TextInputType.name,
//       decoration: InputDecoration(
//         hintText: "e.g., Samsung Galaxy F41 Mobile",
//         labelText: "Product Title",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (titleFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget buildVariantField() {
//     return TextFormField(
//       controller: variantFieldController,
//       keyboardType: TextInputType.name,
//       decoration: InputDecoration(
//         hintText: "e.g., Fusion Green",
//         labelText: "Variant",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (variantFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget buildHighlightsField() {
//     return TextFormField(
//       controller: highlightsFieldController,
//       keyboardType: TextInputType.multiline,
//       decoration: InputDecoration(
//         hintText:
//             "e.g., RAM: 4GB | Front Camera: 30MP | Rear Camera: Quad Camera Setup",
//         labelText: "Highlights",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (highlightsFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       maxLines: null,
//     );
//   }

//   Widget buildDescriptionField() {
//     return TextFormField(
//       controller: desciptionFieldController,
//       keyboardType: TextInputType.multiline,
//       decoration: InputDecoration(
//         hintText:
//             "e.g., This a flagship phone under made in India, by Samsung. With this device, Samsung introduces its new F Series.",
//         labelText: "Description",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (desciptionFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       maxLines: null,
//     );
//   }

//   Widget buildSellerField() {
//     return TextFormField(
//       controller: sellerFieldController,
//       keyboardType: TextInputType.name,
//       decoration: InputDecoration(
//         hintText: "e.g., HighTech Traders",
//         labelText: "Seed Company",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (sellerFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget buildOriginalPriceField() {
//     return TextFormField(
//       controller: originalPriceFieldController,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         hintText: "e.g., 5999.0",
//         labelText: "Original Price (in INR)",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (originalPriceFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget buildDiscountPriceField() {
//     return TextFormField(
//       controller: discountPriceFieldController,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         hintText: "e.g., 2499.0",
//         labelText: "Discount Price (in INR)",
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//       ),
//       validator: (_) {
//         if (discountPriceFieldController.text.isEmpty) {
//           return FIELD_REQUIRED_MSG;
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Future<void> saveProductButtonCallback(BuildContext context) async {
//     if (validateBasicDetailsForm() == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Erros in Basic Details Form"),
//         ),
//       );
//       return;
//     }
//     if (validateDescribeProductForm() == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Errors in Describe Product Form"),
//         ),
//       );
//       return;
//     }
//     final productDetails = Provider.of<ProductDetails>(context, listen: false);
//     if (productDetails.selectedImages.length < 1) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Upload atleast One Image of Product"),
//         ),
//       );
//       return;
//     }
//     if (productDetails.productType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Please select Product Type"),
//         ),
//       );
//       return;
//     }
//     if (productDetails.searchTags.length < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Add atleast 3 search tags"),
//         ),
//       );
//       return;
//     }
//     String? productId;
//     String snackbarMessage = "";
//     try {
//       product!.productType = productDetails.productType;
//       //   product!.searchTags = productDetails.searchTags;
//       final productUploadFuture = newProduct
//           ? ProductDatabaseHelper().addUsersProduct(product!)
//           : ProductDatabaseHelper().updateUsersProduct(product!);
//       productUploadFuture.then((value) {
//         productId = value;
//       });
//       await showDialog(
//         context: context,
//         builder: (context) {
//           return AsyncProgressDialog(
//             productUploadFuture,
//             message:
//                 Text(newProduct ? "Uploading Product" : "Updating Product"),
//           );
//         },
//       );
//       if (productId != null) {
//         snackbarMessage = "Product Info updated successfully";
//       } else {
//         throw "Couldn't update product info due to some unknown issue";
//       }
//     } on FirebaseException catch (e) {
//       Logger().w("Firebase Exception: $e");
//       snackbarMessage = "Something went wrong";
//     } catch (e) {
//       Logger().w("Unknown Exception: $e");
//       snackbarMessage = e.toString();
//     } finally {
//       Logger().i(snackbarMessage);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(snackbarMessage),
//         ),
//       );
//     }

//     if (productId == null) return;
//     bool allImagesUploaded = false;
//     try {
//       allImagesUploaded = await uploadProductImages(productId!);
//       if (allImagesUploaded == true) {
//         snackbarMessage = "All images uploaded successfully";
//       } else {
//         throw "Some images couldn't be uploaded, please try again";
//       }
//     } on FirebaseException catch (e) {
//       Logger().w("Firebase Exception: $e");
//       snackbarMessage = "Something went wrong";
//     } catch (e) {
//       Logger().w("Unknown Exception: $e");
//       snackbarMessage = "Something went wrong";
//     } finally {
//       Logger().i(snackbarMessage);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(snackbarMessage),
//         ),
//       );
//     }
//     // List<String> downloadUrls = productDetails.selectedImages
//     //     .map((e) => e.imgType == ImageType.network ? e.path : null)
//     //     .toList();
//     List<String> downloadUrls = productDetails.selectedImages
//         .where((e) => e.imgType == ImageType.network)
//         .map((e) => e.path)
//         .where((path) => path != null) // Filter out null values
//         .cast<String>() // Cast to List<String>
//         .toList();

//     bool productFinalizeUpdate = false;
//     try {
//       final updateProductFuture = ProductDatabaseHelper()
//           .updateProductsImages(productId!, downloadUrls);
//       productFinalizeUpdate = await showDialog(
//         context: context,
//         builder: (context) {
//           return AsyncProgressDialog(
//             updateProductFuture,
//             message: Text("Saving Product"),
//           );
//         },
//       );
//       if (productFinalizeUpdate == true) {
//         snackbarMessage = "Product uploaded successfully";
//       } else {
//         throw "Couldn't upload product properly, please retry";
//       }
//     } on FirebaseException catch (e) {
//       Logger().w("Firebase Exception: $e");
//       snackbarMessage = "Something went wrong";
//     } catch (e) {
//       Logger().w("Unknown Exception: $e");
//       snackbarMessage = e.toString();
//     } finally {
//       Logger().i(snackbarMessage);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(snackbarMessage),
//         ),
//       );
//     }
//     Navigator.pop(context);
//   }

//   Future<bool> uploadProductImages(String productId) async {
//     bool allImagesUpdated = true;
//     final productDetails = Provider.of<ProductDetails>(context, listen: false);
//     for (int i = 0; i < productDetails.selectedImages.length; i++) {
//       if (productDetails.selectedImages[i].imgType == ImageType.local) {
//         print("Image being uploaded: " + productDetails.selectedImages[i].path);
//         String? downloadUrl;
//         //   try {
//         final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
//             File(productDetails.selectedImages[i].path),
//             ProductDatabaseHelper().getPathForProductImage(productId, i));
//         downloadUrl = await showDialog(
//           context: context,
//           builder: (context) {
//             return AsyncProgressDialog(
//               imgUploadFuture,
//               message: Text(
//                   "Uploading Images ${i + 1}/${productDetails.selectedImages.length}"),
//             );
//           },
//         );
//         // } on FirebaseException catch (e) {
//         //   Logger().w("Firebase Exception: $e");
//         // } catch (e) {
//         //   Logger().w("Firebase Exception: $e");
//         // } finally {
//         print(downloadUrl);
//         if (downloadUrl != null) {
//           productDetails.selectedImages[i] =
//               CustomImage(imgType: ImageType.network, path: downloadUrl);
//         } else {
//           allImagesUpdated = false;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Couldn't upload image ${i + 1} due to some issue"),
//             ),
//           );
//         }
//         // }
//       }
//     }
//     return allImagesUpdated;
//   }

//   Future<void> addImageButtonCallback({int? index}) async {
//     final productDetails = Provider.of<ProductDetails>(context, listen: false);
//     if (index == null && productDetails.selectedImages.length >= 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Max 3 images can be uploaded")));
//       return;
//     }
//     String? path;
//     String snackbarMessage = "apple";
//     try {
//       path = await chooseImageFromLocalFiles(context);
//       print(path);
//       if (path == null) {
//         throw LocalImagePickingUnknownReasonFailureException();
//       }
//     } on LocalFileHandlingException catch (e) {
//       // Logger().i("Local File Handling Exception: $e");
//       print(e);
//       snackbarMessage = e.toString();
//     } catch (e) {
//       print(e);
//       // Logger().i("Unknown Exception: $e");
//       snackbarMessage = e.toString();
//     } finally {
//       if (snackbarMessage != null) {
//         //  Logger().i(snackbarMessage);
//         print(snackbarMessage);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(snackbarMessage),
//           ),
//         );
//       }
//     }
//     if (path == null) {
//       return;
//     }
//     if (index == null) {
//       productDetails.addNewSelectedImage(
//           CustomImage(imgType: ImageType.local, path: path));
//     } else {
//       productDetails.setSelectedImageAtIndex(
//           CustomImage(imgType: ImageType.local, path: path), index);
//     }
//   }
// }
