import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../size_config.dart';

class ProductReviewDialog extends StatefulWidget {
  final Review review;
  final String ProductId;
  ProductReviewDialog({
    required this.review,
    required this.ProductId,
  });

  @override
  State<ProductReviewDialog> createState() => _ProductReviewDialogState();
}

class _ProductReviewDialogState extends State<ProductReviewDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.ProductId);
    return SimpleDialog(
      title: Center(
        child: Text(
          "Review",
        ),
      ),
      children: [
        Center(
          child: RatingBar.builder(
            initialRating: widget.review.rating.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              widget.review.rating = rating.round();
            },
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(20)),
        Center(
          child: TextFormField(
            initialValue: widget.review.feedback,
            decoration: InputDecoration(
              hintText: "Feedback of Product",
              labelText: "Feedback (optional)",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            onChanged: (value) {
              widget.review.feedback = value;
            },
            maxLines: null,
            maxLength: 150,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(10)),
        Center(
          child: DefaultButton(
            text: "Release payment",
            press: () async {
              await UserDatabaseHelper()
                  .updatePaymentStatusToDone(widget.ProductId);
              Navigator.pop(context, widget.review);
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Center(
          child: DefaultButton(
            text: "Submit",
            press: () {
              Navigator.pop(context, widget.review);
            },
          ),
        ),
      ],
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
