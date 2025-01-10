import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/view_google_map.dart';
import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("A fab has appeared"),
        child: SingleUser().getUser()?.driver == true
            ? const Icon(Icons.add)
            : const Icon(Icons.album),
      ),
      body: const Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(hintText: "Search"),
          ),
          // TODO: Put google maps here
          Expanded(child: ViewGoogleMap()),
        ],
      ),
    );
  }
}
