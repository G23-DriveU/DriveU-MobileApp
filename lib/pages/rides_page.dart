import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/trip_list_tile.dart';
import 'package:flutter/material.dart';

// Display all of the rides for a user. Either requests, or past rides
class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  // Store the past trips into a list
  List<PastTrip>? previousTrips;

  @override
  void initState() {
    super.initState();
    // Load planned rides and previous rides
  }

  // Load the past trips as both a rider and driver
  Future<List<PastTrip>> _loadPastTrips() async {
    return await TripApi()
        .getPreviousTrips({"userId": SingleUser().getUser()!.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const ListTile(
            title: Text("My Planned Rides"),
          ),
          // TODO: Some listview builder
          const ListTile(
            title: Text("My Previous Rides"),
          ),
          FutureBuilder<List<PastTrip>>(
            future: TripApi().getPreviousTrips(
                {"userId": SingleUser().getUser()!.id.toString()}),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                // TODO: Deal with this when it is empty
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => TripListTile(
                            pastTrip: snapshot.data![index],
                          )),
                );
              } else {
                return const ListTile(
                  title: Text("No Past Trips"),
                );
              }
            },
          ),
        ],
      )),
    );
  }
}
