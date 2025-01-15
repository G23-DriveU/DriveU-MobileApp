import 'package:flutter/material.dart';

// Display all of the rides for a user. Either requests, or past rides
class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  @override
  void initState() {
    super.initState();
    // Load planned rides and previous rides
  }

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
