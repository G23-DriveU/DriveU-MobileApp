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
            child: Stack(
              children: [
                // White Border (Placed beneath the black border)
                Container(
                  margin: const EdgeInsets.fromLTRB(5.0, 5.0, 15.0, 5.0), // Moves inward
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 5.0), // White border
                    borderRadius: BorderRadius.circular(10), // Rectangular look
                  ),
                ),

                // Thicker Black Border (Placed over the white border and around the search bar)
                Container(
                  margin: const EdgeInsets.fromLTRB(4.0, 4.0, 14.0, 4.0), // Moves inward
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.black, width: 4.0), // Thicker black border
                    borderRadius: BorderRadius.circular(8), // Slightly rectangular
                  ),
                ),

                // Main Search Bar (LocationSuggest Widget)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Ensures full white background
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0), // Pushes the inner container inward
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Ensures full white overlay
                        borderRadius: BorderRadius.circular(27), // Slightly smaller than outer
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0), // Adjust spacing inside
                        child: LocationSuggest(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





/*import 'package:driveu_mobile_app/model/map_state.dart';
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
            child: Stack(
              children: [
                // Main Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Ensures full white background
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
                    padding: const EdgeInsets.all(3.0), // Pushes the inner container inward
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // White overlay to cover any unwanted colors
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0), // Adjust spacing inside
                        child: LocationSuggest(),
                      ),
                    ),
                  ),
                ),
                // Black Outline Border (Overlapping & More Inward)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(6.0, 6.0, 30.0, 6.0), // Moves border inward
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 4.0), // Thicker border
                      borderRadius: BorderRadius.circular(10), // More rectangular shape
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
