// import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
// import 'package:e_commerce_app_flutter/services/database/seller_database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl/intl.dart';

import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/services/database/seller_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<OrderedProduct>> _ordersFuture;
  final SellerDatabaseHelper _databaseHelper = SellerDatabaseHelper();
  final ProductDatabaseHelper _productDatabaseHelper = ProductDatabaseHelper();
  final UserDatabaseHelper _userDatabaseHelper = UserDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _databaseHelper.getSellerOrders();
  }

  void _updateOrderStatus(OrderedProduct order, String newStatus) {
    try {
      // Validate and update order status
      order.updateOrderStatus(newStatus);

      // Update in database
      _databaseHelper.updateOrderStatus(order.id, newStatus).then((_) {
        // Refresh the orders list
        setState(() {
          _ordersFuture = _databaseHelper.getSellerOrders();
        });

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        // Show error if update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      // Show error if status update is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderedProduct>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6E44FF),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/empty_box.svg',
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderedProduct order) {
    // Determine available next statuses
    List<String> availableStatuses = OrderedProduct.orderStatusFlow
        .where((status) => order.canUpdateStatus(status))
        .toList();

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchOrderDetails(order),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Container(); // or an error widget
        }

        final productName = snapshot.data!['productName'] ?? 'Unknown Product';
        final buyerName = snapshot.data!['buyerName'] ?? 'Unknown Buyer';
        final buyerLocation =
            snapshot.data!['buyerLocation'] ?? 'Unknown Location';

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID: ${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E44FF),
                      ),
                    ),
                    Text(
                      order.orderStatus ?? 'Pending',
                      style: TextStyle(
                        color: _getStatusColor(order.orderStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Product: $productName',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Buyer: $buyerName',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Location: $buyerLocation',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Ordered on: ${_formatDate(order.orderDate)}',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Product Quantity: ${order.quantity ?? 0}',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement chat functionality with buyer
                        print('Chat with buyer ${order.buyerId}');
                      },
                      icon: Icon(Icons.chat_bubble_outline),
                      label: Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6E44FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String newStatus) {
                        _updateOrderStatus(order, newStatus);
                      },
                      itemBuilder: (BuildContext context) {
                        return availableStatuses.map((String status) {
                          return PopupMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList();
                      },
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.alt_route),
                        label: Text('Update Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchOrderDetails(OrderedProduct order) async {
    // Fetch product name
    final product =
        await _productDatabaseHelper.getProductWithID(order.productUid);
    final productName = product?.name ?? 'Unknown Product';

    // Fetch buyer details
    final buyerDetails =
        await _userDatabaseHelper.getUserDetailsById(order.buyerId!);
    final buyerName = buyerDetails?.name ?? 'Unknown Buyer';
    final buyerLocation = buyerDetails?.city ?? 'Unknown Location';

    return {
      'productName': productName,
      'buyerName': buyerName,
      'buyerLocation': buyerLocation,
    };
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'ordered':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

// class OrderScreen extends StatefulWidget {
//   const OrderScreen({Key? key}) : super(key: key);

//   @override
//   _OrderScreenState createState() => _OrderScreenState();
// }

// class _OrderScreenState extends State<OrderScreen> {
//   late Future<List<OrderedProduct>> _ordersFuture;
//   final SellerDatabaseHelper _databaseHelper = SellerDatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     _ordersFuture = _databaseHelper.getSellerOrders();
//   }

//   void _updateOrderStatus(OrderedProduct order, String newStatus) {
//     try {
//       // Validate and update order status
//       order.updateOrderStatus(newStatus);

//       // Update in database
//       _databaseHelper.updateOrderStatus(order.id, newStatus).then((_) {
//         // Refresh the orders list
//         setState(() {
//           _ordersFuture = _databaseHelper.getSellerOrders();
//         });

//         // Show success snackbar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Order status updated to $newStatus'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }).catchError((error) {
//         // Show error if update fails
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update order: ${error.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       });
//     } catch (e) {
//       // Show error if status update is invalid
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F7),
//       appBar: AppBar(
//         title: Text(
//           'Orders',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<OrderedProduct>>(
//         future: _ordersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   Color(0xFF6E44FF),
//                 ),
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/icons/empty_box.svg',
//                     height: 200,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'No orders yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final order = snapshot.data![index];
//               return _buildOrderCard(order);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderCard(OrderedProduct order) {
//     // Determine available next statuses
//     List<String> availableStatuses = OrderedProduct.orderStatusFlow
//         .where((status) => order.canUpdateStatus(status))
//         .toList();

//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Order ID: ${order.id.substring(0, 8) ?? 'N/A'}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF6E44FF),
//                   ),
//                 ),
//                 Text(
//                   order.orderStatus ?? 'Pending',
//                   style: TextStyle(
//                     color: _getStatusColor(order.orderStatus),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Ordered on: ${_formatDate(order.orderDate)}',
//               style: TextStyle(
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Product Quantity: ${order.quantity ?? 0}',
//               style: TextStyle(
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // TODO: Implement chat functionality
//                     print('Chat with buyer ${order.buyerId}');
//                   },
//                   icon: Icon(Icons.chat_bubble_outline),
//                   label: Text('Chat'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF6E44FF),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (String newStatus) {
//                     _updateOrderStatus(order, newStatus);
//                   },
//                   itemBuilder: (BuildContext context) {
//                     return availableStatuses.map((String status) {
//                       return PopupMenuItem<String>(
//                         value: status,
//                         child: Text(status),
//                       );
//                     }).toList();
//                   },
//                   child: ElevatedButton.icon(
//                     onPressed: null,
//                     icon: Icon(Icons.alt_route),
//                     label: Text('Update Status'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'Unknown Date';
//     try {
//       final DateTime date = DateTime.parse(dateString);
//       return DateFormat('MMM dd, yyyy').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'ordered':
//         return Colors.blue;
//       case 'processing':
//         return Colors.orange;
//       case 'shipped':
//         return Colors.purple;
//       case 'delivered':
//         return Colors.green;
//       case 'completed':
//         return Colors.teal;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// // import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
// // import 'package:e_commerce_app_flutter/services/database/seller_database_helper.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:intl/intl.dart';

// // class OrderScreen extends StatefulWidget {
// //   const OrderScreen({Key? key}) : super(key: key);

// //   @override
// //   _OrderScreenState createState() => _OrderScreenState();
// // }

// // class _OrderScreenState extends State<OrderScreen> {
// //   late Future<List<OrderedProduct>> _ordersFuture;
// //   final SellerDatabaseHelper _databaseHelper = SellerDatabaseHelper();
// //   // final ChatService _chatService = ChatService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _ordersFuture = _databaseHelper.getSellerOrders();
// //   }

// //   void _markOrderCompleted(OrderedProduct order) {
// //     // Implement order completion logic
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('Order marked as completed'),
// //         backgroundColor: Colors.green,
// //       ),
// //     );
// //   }

// //   // void _initiateChat(String buyerId) {
// //   //   // Implement chat initiation logic
// //   //   Navigator.push(
// //   //     context,
// //   //     PageTransition(
// //   //       type: PageTransitionType.rightToLeft,
// //   //       child: ChatScreen(buyerId: buyerId),
// //   //     ),
// //   //   );
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F5F7),
// //       appBar: AppBar(
// //         title: Text(
// //           'Orders',
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         centerTitle: true,
// //       ),
// //       body: FutureBuilder<List<OrderedProduct>>(
// //         future: _ordersFuture,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(
// //               child: CircularProgressIndicator(
// //                 valueColor: AlwaysStoppedAnimation<Color>(
// //                   Color(0xFF6E44FF),
// //                 ),
// //               ),
// //             );
// //           }

// //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   SvgPicture.asset(
// //                     'assets/icons/empty_box.svg',
// //                     height: 200,
// //                   ),
// //                   SizedBox(height: 20),
// //                   Text(
// //                     'No orders yet',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black54,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           }

// //           return ListView.builder(
// //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //             itemCount: snapshot.data!.length,
// //             itemBuilder: (context, index) {
// //               final order = snapshot.data![index];
// //               return _buildOrderCard(order);
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildOrderCard(OrderedProduct order) {
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(15),
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black12,
// //             blurRadius: 10,
// //             offset: Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'Order ID: ${order.id?.substring(0, 8) ?? 'N/A'}',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF6E44FF),
// //                   ),
// //                 ),
// //                 Text(
// //                   order.paymentStatus ?? 'Pending',
// //                   style: TextStyle(
// //                     color: _getStatusColor(order.paymentStatus),
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 12),
// //             Text(
// //               'Ordered on: ${_formatDate(order.orderDate)}',
// //               style: TextStyle(
// //                 color: Colors.black54,
// //               ),
// //             ),
// //             SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 ElevatedButton.icon(
// //                   onPressed: () {
// //                     print('Chat');
// //                   },
// //                   icon: Icon(Icons.chat_bubble_outline),
// //                   label: Text('Chat'),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Color(0xFF6E44FF),
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                 ),
// //                 ElevatedButton.icon(
// //                   onPressed: () => _markOrderCompleted(order),
// //                   icon: Icon(Icons.check_circle_outline),
// //                   label: Text('Complete'),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatDate(String? dateString) {
// //     if (dateString == null) return 'Unknown Date';
// //     try {
// //       final DateTime date = DateTime.parse(dateString);
// //       return DateFormat('MMM dd, yyyy').format(date);
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }

// //   Color _getStatusColor(String? status) {
// //     switch (status?.toLowerCase()) {
// //       case 'paid':
// //         return Colors.green;
// //       case 'pending':
// //         return Colors.orange;
// //       case 'failed':
// //         return Colors.red;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// // }

// // class ChatScreen extends StatelessWidget {
// //   final String buyerId;

// //   const ChatScreen({Key? key, required this.buyerId}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     // Implement chat screen UI
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Chat'),
// //       ),
// //       body: Center(
// //         child: Text('Chat with Buyer'),
// //       ),
// //     );
// //   }
// // }
