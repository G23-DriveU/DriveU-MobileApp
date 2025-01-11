import 'package:flutter/material.dart';

// Display all of the rides for a user. Either requests, or past rides
class RidesPage extends StatelessWidget {
  const RidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Column(
        children: [
          ListTile(
            title: Text("My Planned Rides"),
          ),
          // TODO: Some listview builder
          ListTile(
            title: Text("My Previous Rides"),
          )
          // TODO: Some listview builder
        ],
      )),
    );
  }
}
