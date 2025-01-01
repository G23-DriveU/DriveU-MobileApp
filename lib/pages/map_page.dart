import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(hintText: "Search"),
          ),
          // TODO: Put google maps here
        ],
      ),
    );
  }
}
