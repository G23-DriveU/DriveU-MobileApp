import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/pages/map_page.dart';
import 'package:driveu_mobile_app/pages/profile_page.dart';
import 'package:driveu_mobile_app/pages/rides_page.dart';
import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    const MapPage(),
    const RidesPage(),
    const ProfilePage()
  ];

  var currentPage = 0;

  @override
  void initState() {
    super.initState();
    // _loadUser();
  }

  void _loadUser() async {
    print("attempting to load user from Home Page");
    // We have the firebaseUid stored, so we can query the user info from the DriveU database
    AppUser? user = await UserApi.getUser({
      'firebaseUid': FirebaseAuth.instance.currentUser!.uid,
      'fcmToken': '12347890'
    });
    setState(() {
      SingleUser().setUser(user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Might remove this since the loading and signing out thing is weird
    return SingleUser().getUser() == null
        ? Column(
            children: [
              const Center(child: CircularProgressIndicator()),
              ElevatedButton(
                  onPressed: () => AuthService().signOut(),
                  child: const Text("Sign Out"))
            ],
          )
        : Scaffold(
            body: _pages[currentPage],
            bottomNavigationBar: BottomNavigationBar(
              onTap: (value) => setState(() => currentPage = value),
              currentIndex: currentPage,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.car_rental),
                  label: "My Rides",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          );
  }
}
