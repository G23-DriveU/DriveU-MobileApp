import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebView extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String? url;
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
    // Rider pay
    if (widget.url != null) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url!))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (url.contains('/after-approval')) {
                // Capture the authorization ID from the url
                String authId = Uri.parse(url).queryParameters['authId']!;

                widget.navigatorKey.currentState?.pop(authId);
                // Navigator.of(context).pop(authId);
              }
              // Handle the case where PayPal failed
              else if (url.contains('/cancel')) {
                widget.navigatorKey.currentState?.pop(null);
              }
            },
          ),
        );
    }
    // Driver log into PayPal
    else {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadFlutterAsset('assets/paypal_login.html')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              print("DEBUG: Displaying url $url");
              if (url.contains('driveu.online/signup')) {
                // Capture the authorization ID from the url
                String code = Uri.parse(url).queryParameters['code']!;

                widget.navigatorKey.currentState?.pop(code);
                // Navigator.of(context).pop(authId);
              }
              // Handle the case where PayPal failed
              else if (url.contains('/cancel')) {
                widget.navigatorKey.currentState?.pop(null);
              }
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
