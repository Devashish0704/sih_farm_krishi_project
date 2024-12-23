import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Atoms/home_screen_floating_button.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/category_with_products.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/home_screen_app_bar.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/home_screen_carousel.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/home_screen_category_builder.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/UI/Widgets/Organisms/home_screen_search_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        floatingActionButton: HomeScreenFloatingNavigationBar(),
        primary: true,
        body: Stack(
          children: [
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                HomeScreenAppBar(),
                HomeScreenSearchBar(),
                HomeScreenCarousel(),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 30,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),
                HomeScreenCateogoryWidget(),
                CatgorywithProducts(),
                CatgorywithProducts(
                  title: "Personal Care",
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 90,
                  ),
                ),
              ],
            ),
            BottomStickyContainer()
          ],
        ),
      ),
    );
  }
}
