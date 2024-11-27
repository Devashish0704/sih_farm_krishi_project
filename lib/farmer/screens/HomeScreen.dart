import 'package:e_commerce_app_flutter/farmer/screens/VideoScreen.dart';
import 'package:e_commerce_app_flutter/farmer/screens/playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import './MenuScreen.dart';
import './MandiScreen/MandiScreen.dart';
import './MandiScreen/state/MandiBloc.dart';
import './ProductsScreen/ProductsScreen.dart';
import '../services/LocalizationProvider.dart';
import './ProductsScreen/state/ProductsBloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Uncomment and add your ProductsScreen if needed
    // Provider<ProductsBloc>(
    //   create: (context) => ProductsBloc(),
    //   dispose: (context, blog) => blog.dispose(),
    //   child: ProductsScreen(),
    // ),
    MenuScreen(),
    Playlist(),
    Provider<MandiBloc>(
      create: (context) => MandiBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: MandiScreen(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Uncomment and add your ProductsScreen if needed
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.shopping_cart),
          //   label: 'Market',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: 'Mandi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class MandiBloc {
  void dispose() {}
}
