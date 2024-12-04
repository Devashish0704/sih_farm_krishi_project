import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../VideoScreen.dart';
import 'local_widgets/ProductsList.dart';
import '../../services/LocalizationProvider.dart';
import 'state/ProductsBloc.dart';

class ProductsScreen extends StatefulWidget {
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
        title: Text(isEnglish ? 'Products' : 'उत्पाद'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Container(
              width: MediaQuery.of(context).size.width,
              child: header(context, isEnglish),
            ),
            Expanded(
              child: ProductsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget header(BuildContext context, bool isEnglish) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(isEnglish ? 'Shop' : 'दुकान',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                fontSize: isEnglish ? 20 : 24,
              )),
          IconButton(
            icon: Icon(
              Icons.help,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => VideoScreen(
                  isEnglish ? 'Shop' : 'दुकान',
                  isEnglish
                      ? TUTORIAL_URL_MANDI_ENGLISH
                      : TUTORIAL_URL_HOME_HINDI,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
