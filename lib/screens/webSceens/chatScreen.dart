import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  final String userId;
  final String talkerId;
  final String productId;
  const ChatScreen(
      {Key? key,
      required this.userId,
      required this.talkerId,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    print(
        "https://sih-chat-app-frntnd.vercel.app/chat/${userId}/${talkerId}}/${productId} ");
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Text(
      //     "Chat Section",
      //     style: TextStyle(
      //       fontFamily: 'Lato',
      //       fontSize: 22,
      //       color: Colors.black.withOpacity(0.8),
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.black.withOpacity(0.8),
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(20),
        child: WebViewsWidget(
            url:
                "https://sih-chat-app-frntnd.vercel.app/chat/${userId}/${talkerId}/${productId}"),
      ),
    );
  }
}

class WebViewsWidget extends StatefulWidget {
  final String url;

  const WebViewsWidget({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewsWidgetState createState() => _WebViewsWidgetState();
}

class _WebViewsWidgetState extends State<WebViewsWidget> {
  @override
  void initState() {
    super.initState();
    _launchURL(); // Launch the URL on init
  }

  // Function to launch the URL
  Future<void> _launchURL() async {
    final url = widget.url;

    final Uri _url = Uri.parse(url);

    // Check if the URL can be launched
    // if (await canLa (url)) {
    await launchUrl(_url); // Launch the URL in the browser
    // } else {
    //   throw 'Could not launch $url';  // Error handling
    // }
  }

  @override
  Widget build(BuildContext context) {
    // You can show a loading indicator while the URL is launching
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Launching URL"),
      // ),
      body: Center(
        child: CircularProgressIndicator(), // Indicate loading state
      ),
    );
  }
}


// class WebViewsWidget extends StatefulWidget {
//   final String url;

//   const WebViewsWidget({Key? key, required this.url}) : super(key: key);

//   @override
//   _WebViewsWidgetState createState() => _WebViewsWidgetState();
// }

// class _WebViewsWidgetState extends State<WebViewsWidget> {
//   late final WebViewController _controller;
//   double _progress = 0.0;
//   bool _isLoading = true;

//   // Future<void> requestPermissions() async {
//   //   // Request permission for audio and camera if necessary
//   //   var status = await Permission.camera.request();
//   //   if (!status.isGranted) {
//   //     // Handle the case where permission is denied
//   //     print("Camera permission not granted");
//   //   }

//   //   status = await Permission.microphone.request();
//   //   if (!status.isGranted) {
//   //     // Handle the case where permission is denied
//   //     print("Microphone permission not granted");
//   //   }
//   // }
  

//   @override
//   void initState() {
//     super.initState();
    
//     // requestPermissions();
//     // _controller = WebViewController()
//     //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     //   ..setBackgroundColor(Colors.transparent)
//     //   ..setNavigationDelegate(
//     //     NavigationDelegate(
//     //       onPageStarted: (url) {
//     //         setState(() {
//     //           _isLoading = true;
//     //         });
//     //       },
//     //       onPageFinished: (url) {
//     //         setState(() {
//     //           _isLoading = false;
//     //           _controller
//     //               .runJavaScript("document.body.style.overflow = 'hidden';");
//     //         });
//     //       },
//     //       // onPermissionRequest: (PermissionRequest request) async {
//     //       //   // Handle permission requests from WebView
//     //       //   await _requestPermissions();
//     //       //   return PermissionRequestResponse(
//     //       //     resources: request.resources,
//     //       //     action: PermissionRequestResponseAction.grant,
//     //       //   );
//     //       // },
//     //     ),
//     //   )
//     //   ..loadRequest(Uri.parse(widget.url));

// //     _controller.runJavaScript("""
// //     navigator.mediaDevices.getUserMedia = function(constraints) {
// //         return new Promise((resolve, reject) => {
// //             resolve(); // Simulate granted permission
// //         });
// //     };
// // """);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//     // return Stack(
//     //   children: [
//     //     WebViewWidget(controller: _controller),
//     //     if (_isLoading)
//     //       LinearProgressIndicator(
//     //         value: _progress,
//     //         backgroundColor: Colors.grey[200],
//     //         color: Colors.blue,
//     //       ),
//     //   ],
//     // );
//   }
// }


// // class WebViewsWidget extends StatefulWidget {
// //   final String url;

// //   const WebViewsWidget({Key? key, required this.url}) : super(key: key);

// //   @override
// //   _WebViewsWidgetState createState() => _WebViewsWidgetState();
// // }

// // class _WebViewsWidgetState extends State<WebViewsWidget> {
// //   late final WebViewController _controller;
// //   double _progress = 0.0;
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // _controller = WebViewController()
// //     //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //     //   ..setBackgroundColor(Colors.transparent)
// //     //   ..setNavigationDelegate(NavigationDelegate(
// //     //     onPageFinished: (String url) {
// //     //       // Disable scrolling using JavaScript
// //     //       _controller.runJavaScript("document.body.style.overflow = 'hidden';");
// //     //     },
// //     //   ))
// //     //   ..loadRequest(Uri.parse(widget.url));
// //     _controller = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       ..setBackgroundColor(Colors.transparent)
// //       ..setNavigationDelegate(NavigationDelegate(
// //         onPageStarted: (url) {
// //           setState(() {
// //             _isLoading = true;
// //           });
// //         },
// //         onPageFinished: (url) {
// //           setState(() {
// //             _isLoading = false;
// //             _controller
// //                 .runJavaScript("document.body.style.overflow = 'hidden';");
// //           });
// //         },
// //         // onNavigationRequest: (NavigationRequest request) {
// //         //   if (request.url.startsWith("https://your-allowed-domain.com")) {
// //         //     return NavigationDecision.navigate;
// //         //   }
// //         //   return NavigationDecision.prevent;
// //         // },
// //       ))
// //       ..loadRequest(Uri.parse(widget.url));

// //     // _controller = WebViewController()
// //     //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //     //   ..loadRequest(Uri.parse(widget.url));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         //  WebViewWidget(controller: _controller)
// //         WebViewWidget(
// //           controller: _controller,
// //         ),
// //         if (_isLoading)
// //           LinearProgressIndicator(
// //             value: _progress,
// //             backgroundColor: Colors.grey[200],
// //             color: Colors.blue,
// //           ),
// //         // if (_isLoading)
// //         //   Center(
// //         //     child: CircularProgressIndicator(),
// //         //   ),
// //       ],
// //     );
// //   }
// // }
