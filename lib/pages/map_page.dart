import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/create_ride_dialog.dart';
import 'package:driveu_mobile_app/widgets/map_fab.dart';
import 'package:driveu_mobile_app/widgets/select_radius_dialog.dart';
import 'package:driveu_mobile_app/widgets/view_google_map.dart';
import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if ((SingleUser().getUser()?.driver == true)) {
            return const CreateRideDialog();
          } else {
            return const SelectRadiusDialog();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MapFab(
        icon: SingleUser().getUser()?.driver == true ? Icons.add : Icons.album,
        onPressed: () => _showDialog(context),
      ),
      body: const Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(hintText: "Search"),
          ),
          Expanded(child: ViewGoogleMap()),
        ],
      ),
    );
  }
}
