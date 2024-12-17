import 'package:driveu_mobile_app/firebase_options.dart';
import 'package:driveu_mobile_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
