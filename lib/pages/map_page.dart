import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/map%20page/create_ride_dialog.dart';
import 'package:driveu_mobile_app/widgets/map%20page/location_suggest.dart';
import 'package:driveu_mobile_app/widgets/map%20page/map_fab.dart';
import 'package:driveu_mobile_app/widgets/map%20page/select_radius_dialog.dart';
import 'package:driveu_mobile_app/widgets/map%20page/view_google_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  // Show a dialog for either
  // 1) Setting search radius if user is a rider
  // 2) Creating rides if the user is a driver
  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if ((SingleUser().getUser()?.driver == true)) {
            return const CreateRideDialog();
          } else {
            // Pass a callback to the FAB which updates the MapState
            return SelectRadiusDialog(onRadiusSelected: (radius, roundTrip) {
              Provider.of<MapState>(context, listen: false).setRadius(radius);
              Provider.of<MapState>(context, listen: false)
                  .setWantRoundTrip(roundTrip);
            });
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
      body: Stack(
        children: [
          const ViewGoogleMap(),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LocationSuggest(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
