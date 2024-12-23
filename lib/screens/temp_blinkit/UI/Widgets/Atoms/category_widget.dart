import 'package:e_commerce_app_flutter/screens/temp_blinkit/Screens/products_screen.dart';
import 'package:e_commerce_app_flutter/screens/temp_blinkit/constants.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key, required this.index});

  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(
        //   context,
        //   '/products',
        //   arguments: kCategoriesTitles[index],
        // );
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsScreen(
                categoryName: kCategoriesTitles[index],
              ),
            ));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffEEF5FF),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Image.asset(
              // 'Assets/Categories/${index + 1}.png',
              'assets/images/ps4_console_blue_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Text(
            kCategoriesTitles[index],
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }
}
