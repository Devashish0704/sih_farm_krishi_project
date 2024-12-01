import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './VideoScreen.dart';

class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;
  final String videoUrl;

  WebViewScreen(this.title, this.url, this.videoUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 22,
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black.withOpacity(0.8),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help,
              color: Colors.black.withOpacity(0.8),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => VideoScreen(title, videoUrl),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: WebViewsWidget(url: url),
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
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //  WebViewWidget(controller: _controller)
        WebViewWidget(
          controller: _controller,
          // onProgress: (progress) {
          //   setState(() {
          //     _progress = progress / 100.0;
          //   });
          // },
          // onPageStarted: (url) {
          //   setState(() {
          //     _isLoading = true;
          //   });
          // },
          // onPageFinished: (url) {
          //   setState(() {
          //     _isLoading = false;
          //   });
          // },
        ),
        if (_isLoading)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
          ),
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
