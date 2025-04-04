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
        selectedItemColor: Colors.teal, // 🟢 Teal for selected items
        unselectedItemColor: const Color.fromARGB(255, 113, 196, 186), // Light teal for unselected
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Keeps background neutral
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 28),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 28),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental, size: 28),
            label: "My Rides",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
