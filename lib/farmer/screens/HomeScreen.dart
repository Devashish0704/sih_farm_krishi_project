import 'package:e_commerce_app_flutter/farmer/screens/VideoScreen.dart';
import 'package:e_commerce_app_flutter/farmer/screens/farmers_home_screen.dart';
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

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      FarmerHomeScreen(),
      Playlist(),
      Provider<MandiBloc>(
        create: (context) => MandiBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: MandiScreen(),
      ),
    ];
  }

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
    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.amber[800],
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: isEnglish ? 'Home' : 'घर',
                ),
                GButton(
                  icon: LineIcons.video,
                  text: isEnglish ? 'Videos' : 'वीडियो',
                ),
                GButton(
                  icon: LineIcons.shoppingBasket,
                  text: isEnglish ? 'Mandi' : 'मंडी',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

class MandiBloc {
  void dispose() {}
}




// import 'package:e_commerce_app_flutter/farmer/screens/VideoScreen.dart';
// import 'package:e_commerce_app_flutter/farmer/screens/farmers_home_screen.dart';
// import 'package:e_commerce_app_flutter/farmer/screens/playlist_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';

// import './MenuScreen.dart';
// import './MandiScreen/MandiScreen.dart';
// import './MandiScreen/state/MandiBloc.dart';
// import './ProductsScreen/ProductsScreen.dart';
// import '../services/LocalizationProvider.dart';
// import './ProductsScreen/state/ProductsBloc.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _pageController = PageController(initialPage: 0);
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     // Uncomment and add your ProductsScreen if needed
//     // Provider<ProductsBloc>(
//     //   create: (context) => ProductsBloc(),
//     //   dispose: (context, blog) => blog.dispose(),
//     //   child: ProductsScreen(),
//     // ),
//     FarmerHomeScreen(),
//     //  MenuScreen(),
//     Playlist(),
//     Provider<MandiBloc>(
//       create: (context) => MandiBloc(),
//       dispose: (context, bloc) => bloc.dispose(),
//       child: MandiScreen(),
//     ),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.jumpToPage(index);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         children: _pages,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           // Uncomment and add your ProductsScreen if needed
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.shopping_cart),
//           //   label: 'Market',
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.menu),
//             label: 'Menu',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_library),
//             label: 'Video',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_grocery_store),
//             label: 'Mandi',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.amber[800],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// class MandiBloc {
//   void dispose() {}
// }
