import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/Product.dart';
import '../../../models/Review.dart';
import '../../../services/database/product_database_helper.dart';
import '../../../constants.dart';
import '../../../size_config.dart';

class ProductReviewsSection extends StatelessWidget {
  final Product product;

  const ProductReviewsSection({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
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
                  'Product Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildOverallRatingWidget(product.rating ?? 0),
              ],
            ),
            SizedBox(height: 16),
            StreamBuilder<List<Review>>(
              stream: ProductDatabaseHelper()
                  .getAllReviewsStreamForProductId(product.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  );
                }

                final reviews = snapshot.data ?? [];

                if (reviews.isEmpty) {
                  return _buildNoReviewsWidget();
                }

                return Column(
                  children: reviews
                      .map((review) => _buildReviewCard(review))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRatingWidget(num rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.star,
            color: kPrimaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsWidget() {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/icons/review.svg",
            color: Colors.grey[400],
            width: 60,
          ),
          SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anonymous',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStarRating(review.rating),
              ],
            ),
            SizedBox(height: 8),
            Text(
              review.feedback ?? '',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int? rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < (rating ?? 0) ? Icons.star : Icons.star_border,
          color: kPrimaryColor,
          size: 20,
        ),
      ),
    );
  }
}


// import 'package:e_commerce_app_flutter/components/top_rounded_container.dart';
// import 'package:e_commerce_app_flutter/models/Product.dart';
// import 'package:e_commerce_app_flutter/models/Review.dart';
// import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:logger/logger.dart';
// import '../../../constants.dart';
// import '../../../size_config.dart';
// import 'review_box.dart';

// class ProductReviewsSection extends StatelessWidget {
//   const ProductReviewsSection({
//     required this.product,
//   });

//   final Product product;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: getProportionateScreenHeight(320),
//       child: Stack(
//         children: [
//           TopRoundedContainer(
//             child: Column(
//               children: [
//                 Text(
//                   "Product Reviews",
//                   style: TextStyle(
//                     fontSize: 21,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: getProportionateScreenHeight(20)),
//                 Expanded(
//                   child: StreamBuilder<List<Review>>(
//                     stream: ProductDatabaseHelper()
//                         .getAllReviewsStreamForProductId(product.id),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         final reviewsList = snapshot.data;
//                         if (reviewsList!.length == 0) {
//                           return Center(
//                             child: Column(
//                               children: [
//                                 SvgPicture.asset(
//                                   "assets/icons/review.svg",
//                                   color: kTextColor,
//                                   width: 40,
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "No reviews yet",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                         return ListView.builder(
//                           physics: BouncingScrollPhysics(),
//                           itemCount: reviewsList.length,
//                           itemBuilder: (context, index) {
//                             return ReviewBox(
//                               review: reviewsList[index],
//                             );
//                           },
//                         );
//                       } else if (snapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       } else if (snapshot.hasError) {
//                         final error = snapshot.error;
//                         Logger().w(error.toString());
//                       }
//                       return Center(
//                         child: Icon(
//                           Icons.error,
//                           color: kTextColor,
//                           size: 50,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.topCenter,
//             child: buildProductRatingWidget(product.rating!),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildProductRatingWidget(num rating) {
//     return Container(
//       width: getProportionateScreenWidth(80),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.amber,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               "$rating",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w900,
//                 fontSize: getProportionateScreenWidth(16),
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Icon(
//             Icons.star,
//             color: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }
// }
