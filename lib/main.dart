import 'package:driveu_mobile_app/firebase_options.dart';
import 'package:driveu_mobile_app/pages/auth_page.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Our client to handle http requests to the API
  final SingleClient _client = SingleClient();

  @override
  void dispose() {
    super.dispose();
    _client.close();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthPage(),
      debugShowCheckedModeBanner: false,
      // TODO: Add the theme data here
      // TODO: Add navigators here
    );
  }
}
