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
      body: Column(
        children: [
          // Search bar
          LocationSuggest(),
          const Expanded(child: ViewGoogleMap()),
        ],
      ),
    );
  }
}
