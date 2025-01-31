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
  Widget build(BuildContext context) {
    // TODO: Might remove this since the loading and signing out thing is weird
    return SingleUser().getUser() == null
        ? const Center(child: CircularProgressIndicator())
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
