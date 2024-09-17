// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../models/Product.dart';
// import './state/ProductsBloc.dart';
// import './state/ProductsState.dart';
// import '../../widgets/ImageInput.dart';
// import '../../routing/Application.dart';
// import '../../widgets/LocationInput.dart';
// import '../../widgets/LoadingSpinner.dart';
// import '../../widgets/CustomTextField.dart';
// import '../../widgets/CustomDarkButton.dart';
// import '../../services/LocalizationProvider.dart';
// import 'local_widgets/UnitsDropdownField.dart';

// class AddProductScreen extends StatefulWidget {
//   final String? productId;
//   final bool isEditing;

//   const AddProductScreen({
//     this.productId,
//     this.isEditing = false,
//   });

//   @override
//   _AddProductScreenState createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _quantityNameController = TextEditingController();

//   File? _imageFile;
//   String? _imageUrl;
//   Position? _position;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.isEditing && widget.productId != null) {
//       // Provider.of<ProductsBloc>(context, listen: false)
//       //     .fetchProduct(widget.productId!, _setProductForEdit);
//     }
//   }

//   void _setUnitName(String crop) {
//     _quantityNameController.text = crop;
//   }

//   void _selectPlace(double lat, double long) {
//     setState(() {
//       _position = Position(
//           latitude: lat,
//           longitude: long,
//           timestamp: DateTime.now(),
//           accuracy: 0.0,
//           altitude: 0.0,
//           altitudeAccuracy: 0.0,
//           heading: 0.0,
//           headingAccuracy: 0.0,
//           speed: 0.0,
//           speedAccuracy: 0.0);
//     });
//   }

//   void _selectImage(File image) {
//     setState(() {
//       _imageFile = image;
//     });
//   }

//   // void _setProductForEdit(Product product) {
//   //   setState(() {
//   //     _titleController.text = product.title;
//   //     _priceController.text = product.price.toString();
//   //     _quantityController.text = product.quantity.toString();
//   //     _quantityNameController.text = product.quantityName;
//   //     _imageUrl = product.imageUrl;
//   //     _position = product.position;
//   //   });
//   // }

//   void _goBack() {
//     Application.router.pop(context, true);
//   }

//   void _addProduct() {
//     final product = Product(
//       title: _titleController.text,
//       price: double.parse(_priceController.text),
//       quantity: int.parse(_quantityController.text),
//       quantityName: _quantityNameController.text,
//       position: _position!,
//     );
//     Provider.of<ProductsBloc>(context, listen: false)
//         .addProduct(product, _imageFile!, _goBack);
//   }

//   void _updateProduct() {
//     final product = Product(
//       title: _titleController.text,
//       price: double.parse(_priceController.text),
//       quantity: int.parse(_quantityController.text),
//       quantityName: _quantityNameController.text,
//       position: _position!,
//       imageUrl: _imageUrl!,
//     );
//     print(product);
    
//     Provider.of<ProductsBloc>(context, listen: false)
//         .updateProduct(widget.productId!, product, _imageFile, _goBack);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

//     return Scaffold(
//       appBar: _buildAppBar(
//         context,
//         widget.productId == null
//             ? (isEnglish ? 'Add Product' : 'उत्पाद जोड़ें')
//             : (isEnglish ? 'Edit Product' : 'उत्पाद संपादित करें'),
//       ),
//       backgroundColor: Colors.white,
//       body: StreamBuilder<ProductsState>(
//         stream: Provider.of<ProductsBloc>(context).state,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data!.isLoading) {
//             return Center(child: loadingSpinner());
//           }
//           return SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 SizedBox(height: 20),
//                 CustomTextField(
//                   controller: _titleController,
//                   icon: FontAwesomeIcons.boxTissue,
//                   labelText: isEnglish ? 'Name of Product' : 'उत्पाद का नाम',
//                 ),
//                 ImageInput(
//                   _selectImage,
//                   imageUrl: _imageUrl,
//                   imageFile: _imageFile,
//                   isEnglish: isEnglish,
//                 ),
//                 LocationInput(
//                   _selectPlace,
//                   position: _position,
//                   isEnglish: isEnglish,
//                 ),
//                 CustomTextField(
//                   controller: _priceController,
//                   icon: FontAwesomeIcons.rupeeSign,
//                   labelText: isEnglish ? 'Price per Item' : 'मूल्य प्रति आइटम',
//                   numeric: true,
//                 ),
//                 CustomTextField(
//                   controller: _quantityController,
//                   icon: FontAwesomeIcons.sortNumericUp,
//                   labelText: isEnglish ? 'Quantity' : 'मात्रा',
//                   numeric: true,
//                 ),
//                 UnitsDropdownField(
//                   defaultValue: _quantityNameController.text,
//                   callback: (s) {
//                     print(s);
//                     _setUnitName;
//                   },
//                   label: isEnglish ? 'Unit of Quantity' : 'मात्रा की इकाई',
//                 ),
//                 SizedBox(height: 20),
//                 customDarkButton(
//                   text: isEnglish ? 'CONFIRM' : 'पुष्टि करें',
//                   icon: FontAwesomeIcons.checkCircle,
//                   onPress: widget.isEditing ? _updateProduct : _addProduct,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   AppBar _buildAppBar(BuildContext context, String title) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       centerTitle: true,
//       title: Text(
//         title,
//         style: TextStyle(
//           fontFamily: 'Lato',
//           fontSize: 22,
//           color: Colors.black.withOpacity(0.8),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios,
//           color: Colors.black.withOpacity(0.8),
//         ),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//     );
//   }
// }
