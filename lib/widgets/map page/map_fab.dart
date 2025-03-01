import 'package:flutter/material.dart';

class MapFab extends StatefulWidget {
  // The icon to display
  IconData icon;
  VoidCallback onPressed;
  // Callback when you click on the button
  MapFab({super.key, required this.icon, required this.onPressed});

  @override
  State<MapFab> createState() => _MapFabState();
}

class _MapFabState extends State<MapFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.teal,
      // If the user is a driver, when they click on the button, they can add a new ride
      // If the user is a rider, they can set a search radius
      onPressed: widget.onPressed,
      // Display the icon
      child: Icon(
        widget.icon,
        color: Colors.white,
      ),
    );
  }
}
