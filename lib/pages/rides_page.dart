import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/future_trip_list_tile.dart';
import 'package:driveu_mobile_app/widgets/past_trip_list_tile.dart';
import 'package:flutter/material.dart';

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

  FutureBuilder<List<FutureTrip>> futureTripDriver() {
    return FutureBuilder<List<FutureTrip>>(
      future: _loadFutureTripsDriver(),
      builder: (context, snapshot) {
        return _buildContent(
          snapshot: snapshot,
          emptyText: "No upcoming trips planned",
          builder: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => FutureTripListTile(
              futureTrip: data[index],
            ),
          ),
        );
      },
    );
  }

  FutureBuilder<List<RideRequest>> futureTripRider() {
    return FutureBuilder<List<RideRequest>>(
      future: _loadFutureTripsRider(),
      builder: (context, snapshot) {
        return _buildContent(
          snapshot: snapshot,
          emptyText: "No upcoming trips planned",
          builder: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => FutureTripListTile(
              rideRequest: data[index],
            ),
          ),
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
