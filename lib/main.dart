import 'package:driveu_mobile_app/firebase_options.dart';
import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/pages/auth_page.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';
import 'package:driveu_mobile_app/services/push_notification_service.dart';
import 'package:driveu_mobile_app/theme/main_theme.dart';
import 'package:driveu_mobile_app/widgets/pay_pal_webview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "e.env");
  await PushNotificationService().initNotifications();


  // CNP allows widgets to check the update of a widget state
  runApp(ChangeNotifierProvider(
      create: (context) => MapState(), child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Our client to handle http requests to the API
  final SingleClient _client = SingleClient();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    _client.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthPage(),
      debugShowCheckedModeBanner: false,
      theme: mainTheme,
      navigatorKey: navigatorKey,
      routes: {
        '/PayPalWebView': (context) => PayPalWebView(
            navigatorKey: navigatorKey,
            // If no url is supplied then it is for drivers to sign up since
            // no prior info is need to process that request.
            url: ModalRoute.of(context)!.settings.arguments == null
                ? null
                : ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}
