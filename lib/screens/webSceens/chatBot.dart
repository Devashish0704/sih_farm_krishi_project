import 'package:e_commerce_app_flutter/screens/webSceens/chatScreen.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class ChatbotScreen extends StatelessWidget {
  final String userId;
  const ChatbotScreen({Key? key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // print("https://ameya-sih.netlify.app/add/produce/${userId}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        // title: Text(
        //   "Fill your Form",
        //   style: TextStyle(
        //     fontFamily: 'Lato',
        //     fontSize: 22,
        //     color: Colors.black.withOpacity(0.8),
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black.withOpacity(0.8),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: WebViewsWidget(
          url: "https://sih-chatbot-app-frntd.onrender.com/chatbot/${userId}"),
    );
  }
}
