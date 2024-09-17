// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../state/ProductsBloc.dart';
// import '../../../routing/Application.dart';
// import '../../../services/Helpers.dart';
// import '../../../widgets/CustomYellowButton.dart';
// import '../../../widgets/ConfirmationDialog.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;
//   final bool userOnly;
//   final bool isEnglish;

//   ProductCard(this.product, this.isEnglish, {this.userOnly = false});

//   void _deleteProductConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => ConfirmationDialog(
//         () => Provider.of<ProductsBloc>(context, listen: false)
//             .deleteProduct(product.id),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
//       padding: const EdgeInsets.all(7.5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               ClipRRect(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(15),
//                   topLeft: Radius.circular(15),
//                 ),
//                 child: Image.network(
//                   product.,
//                   height: 100,
//                   width: 100,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: <Widget>[
//                     _pocketContainer(Icons.restaurant, product.title),
//                     SizedBox(height: 12.5),
//                     Row(
//                       children: <Widget>[
//                         _smallPocketContainer(
//                           FontAwesomeIcons.rupeeSign,
//                           "${product.price.toStringAsFixed(0)} / ${product.quantityName}",
//                         ),
//                         SizedBox(width: 5),
//                         _smallPocketContainer(
//                           FontAwesomeIcons.list,
//                           "${product.quantity} ${product.quantityName}",
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           userOnly
//               ? _editButtonsRow(context, product, isEnglish)
//               : _viewButtonsRow(context, product, isEnglish),
//         ],
//       ),
//     );
//   }

//   Widget _pocketContainer(IconData iconData, String value) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           width: 0.4,
//           color: Colors.grey[400]!,
//         ),
//       ),
//       child: Row(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.green[800],
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 bottomLeft: Radius.circular(15),
//               ),
//             ),
//             padding: const EdgeInsets.all(5),
//             child: Icon(
//               iconData,
//               color: Colors.white,
//               size: 27,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontFamily: 'Lato',
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _smallPocketContainer(IconData iconData, String value) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           width: 0.4,
//           color: Colors.grey[400]!,
//         ),
//       ),
//       child: Row(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.green[800],
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 bottomLeft: Radius.circular(15),
//               ),
//             ),
//             padding: const EdgeInsets.all(6),
//             child: Icon(
//               iconData,
//               color: Colors.white,
//               size: 14,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(6),
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontFamily: 'Lato',
//                 fontSize: 10,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _viewButtonsRow(
//       BuildContext context, Product product, bool isEnglish) {
//     return Container(
//       color: Colors.transparent,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           CustomYellowButton(
//             text: isEnglish ? 'Call' : 'संपर्क',
//             icon: Icons.phone,
//             onPress: () => Helpers.call(product.phoneNumber),
//           ),
//           CustomYellowButton(
//             text: isEnglish ? 'Location' : 'स्थान',
//             icon: Icons.my_location,
//             onPress: () => Helpers.mapForDestination(
//               product.position.latitude,
//               product.position.longitude,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _editButtonsRow(
//       BuildContext context, Product product, bool isEnglish) {
//     return Container(
//       color: Colors.transparent,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           CustomYellowButton(
//             text: isEnglish ? 'Edit' : 'संपादित करें',
//             icon: FontAwesomeIcons.edit,
//             onPress: () => Application.router!
//                 .navigateTo(context, '/edit-product/${product.id}')
//                 .whenComplete(() {
//               Provider.of<ProductsBloc>(context, listen: false).refresh();
//             }),
//           ),
//           CustomYellowButton(
//             text: isEnglish ? 'Delete' : 'मिटाओ',
//             icon: FontAwesomeIcons.trash,
//             onPress: () => _deleteProductConfirmation(context),
//           ),
//         ],
//       ),
//     );
//   }
// }
