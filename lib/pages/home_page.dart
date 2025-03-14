import 'package:driveu_mobile_app/pages/map_page.dart';
import 'package:driveu_mobile_app/pages/profile_page.dart';
import 'package:driveu_mobile_app/pages/rides_page.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
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

  // For some reason if there is a Firebase instance of the user but not Postgres
  // then just log the user out. TODO: Put up a toast message.
  @override
  void initState() {
    super.initState();
    if (SingleUser().getUser() == null) AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
