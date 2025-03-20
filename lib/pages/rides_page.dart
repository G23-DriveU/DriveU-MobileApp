import 'package:driveu_mobile_app/helpers/helpers.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/pages/future_trip_page_driver.dart';
import 'package:driveu_mobile_app/pages/future_trip_page_rider.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/rides%20page/past_trip_list_tile.dart';
import 'package:flutter/material.dart';

// Describe the trip state
enum TripStage {
  notStarted,
  startedFirstLeg,
  pickedUp,
  endFirstLeg,
  startSecondLeg,
  tripEnd
}

class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  // Load the past trips as both a rider and driver
  Future<List<PastTrip>> _loadPastTrips() async {
    return await TripApi()
        .getPreviousTrips({"userId": SingleUser().getUser()!.id.toString()});
  }

  // Based on the API, viewing future trips is different based on drivers and riders.
  // Drivers view their trips through 'FutureTrip' object, while riders view them
  // through 'RideRequests'. Because of this, there are two different Views
  // of which these users view their planned trips.

  Future<List<FutureTrip>> _loadFutureTripsDriver() async {
    return await TripApi().getFutureTrips({
      "driverId": SingleUser().getUser()!.id.toString(),
    });
  }

  Future<List<RideRequest>> _loadFutureTripsRider() async {
    return await TripApi().getRiderFutureTrips(
        {"riderId": SingleUser().getUser()!.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Planned Rides Section
            Expanded(
              child: _buildSection(
                title: "Upcoming Trips",
                icon: Icons.calendar_today,
                // Display either driver or rider pages
                futureBuilder: SingleUser().getUser()!.driver
                    ? futureTripDriver()
                    : futureTripRider(),
              ),
            ),
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
            ),
            // Past Rides Section
            Expanded(
              child: _buildSection(
                title: "Trip History",
                icon: Icons.history,
                futureBuilder: FutureBuilder<List<PastTrip>>(
                  future: _loadPastTrips(),
                  builder: (context, snapshot) {
                    return _buildContent(
                      snapshot: snapshot,
                      emptyText: "No past trips available",
                      builder: (data) => ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) => PastTripListTile(
                          pastTrip: data[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display a page for driver's future trips
  FutureBuilder<List<FutureTrip>> futureTripDriver() {
    return FutureBuilder<List<FutureTrip>>(
      future: _loadFutureTripsDriver(),
      builder: (context, snapshot) {
        return _buildContent(
          snapshot: snapshot,
          emptyText: "No upcoming trips planned",
          builder: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ListTile(
                    title: Text("Your Trip to ${data[index].destination}"),
                    trailing: const Icon(Icons.money),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return FutureTripPageDriver(
                          trip: data[index],
                          stage: getTripStage(data[index], null));
                    })),
                  )),
        );
      },
    );
  }

  // Display a page for the future trips for riders`
  FutureBuilder<List<RideRequest>> futureTripRider() {
    return FutureBuilder<List<RideRequest>>(
      future: _loadFutureTripsRider(),
      builder: (context, snapshot) {
        return _buildContent(
          snapshot: snapshot,
          emptyText: "No upcoming trips planned",
          builder: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ListTile(
                    title: Text(
                        "${data[index].futureTrip!.driver?.name}'s Trip to ${data[index].futureTrip!.destination}"),
                    trailing: const Icon(Icons.car_rental),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return FutureTripPageRider(
                          request: data[index],
                          stage: getTripStage(null, data[index]));
                    })),
                  )),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget futureBuilder,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: futureBuilder),
        ],
      ),
    );
  }

  Widget _buildContent<T>({
    required AsyncSnapshot<List<T>> snapshot,
    required String emptyText,
    required Widget Function(List<T> data) builder,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text("Error: ${snapshot.error}"));
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return builder(snapshot.data!);
  }
}
