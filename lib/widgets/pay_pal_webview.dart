import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebView extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String url;
  const PayPalWebView(
      {super.key, required this.navigatorKey, required this.url});

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController controller;

  // Set up the WebViewController to open the initial PayPal DriveU
  // page and set up a listener to see when the payment has been 'complete'
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url.contains('/after-approval')) {
              // Capture the authorization ID from the url
              String authId = Uri.parse(url).queryParameters['authId']!;

              widget.navigatorKey.currentState?.pop();
            }
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
