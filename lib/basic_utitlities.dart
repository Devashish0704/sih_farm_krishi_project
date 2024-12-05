import 'package:flutter/material.dart';

class Utils {
  static snackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content:
    //         Text(message, style: TextStyle(color: myColorScheme.onBackground)),
    //     // backgroundColor: myColorScheme.background
    //     //  .withOpacity(0.8), // Adjust transparency as needed
    //   ),
    // );
    // Get.snackbar(
    //   title,
    //   message,
    //   backgroundColor: snackbarReddishColor,
    // );
  }
}
