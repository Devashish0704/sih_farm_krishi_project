import 'package:e_commerce_app_flutter/screens/edit_product/edit_product_screen.dart';
import 'package:e_commerce_app_flutter/screens/my_products/my_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './state/ProductsBloc.dart';
import '../../routing/Application.dart';
import 'local_widgets/ProductsList.dart';
import '../../services/LocalizationProvider.dart';

class MyProductsScreen extends StatefulWidget {
  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late ProductsBloc _productsBloc;
  @override
  void initState() {
    super.initState();
    _productsBloc = Provider.of<ProductsBloc>(context, listen: false);
    _productsBloc.refresh(); // Refresh data when screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          isEnglish ? 'My Products' : 'मेरे उत्पाद',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 22,
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black.withOpacity(0.8),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Colors.black.withOpacity(0.8),
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(),
                  )))
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: MyProductsScreens(),
    );
  }
}
