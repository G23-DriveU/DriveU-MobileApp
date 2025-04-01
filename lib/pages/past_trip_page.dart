import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

import 'package:flutter_rating/flutter_rating.dart';
import 'package:location/location.dart';

// Used to display trips for Drivers using the application
// TODO: Display all of the info for the trip in a nice way
// Make sure to delineate between rider and driver here
class PastTripPage extends StatefulWidget {
  final PastTrip trip;
  final LocationData? userPosition;
  const PastTripPage(
      {super.key, required this.trip, required this.userPosition});

  @override
  State<PastTripPage> createState() => _PastTripPageState();
}

class _PastTripPageState extends State<PastTripPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  double _rating = 3;
  late PastTrip trip;

  @override
  void initState() {
    super.initState();

    trip = widget.trip;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

    trip = widget.trip;
  }

  // Determine if user can rate
  bool _isRated() {
    // User is the rider
    if (SingleUser().getUser()!.id != trip.driverId) {
      return trip.driverRated;
    }
    // User is the driver
    else {
      return trip.riderRated;
    }
  }

  void _rateUserDialog(BuildContext context, PastTrip trip) {
    String rateeName = SingleUser().getUser()!.id == trip.driverId
        ? trip.rider!.name
        : trip.driver!.name;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Center(child: Text("Rate $rateeName")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StarRating(
                    rating: _rating,
                    onRatingChanged: (rating) {
                      // Like setState but just for the dialog
                      setDialogState(() {
                        _rating =
                            rating; // Update the rating in the dialog's state
                      });
                    },
                  ),
                  Text("Rating $_rating")
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Who are we rating
                    String ratee = SingleUser().getUser()!.id == trip.driverId
                        ? "rider"
                        : "driver";
                    // The ratee (the one getting rated) id
                    late int rateeId;
                    if (ratee == "driver") {
                      rateeId = trip.driverId;
                    } else {
                      rateeId = trip.riderId;
                    }

                    // Handle the rating submission logic here
                    int res = await TripApi().rateUser({
                      "${ratee}Id": rateeId.toString(),
                      "rating": _rating.toString(),
                      "tripId": trip.id.toString()
                    }, ratee);

                    if (res == 200) {
                      setState(() {
                        if (ratee == "driver") {
                          trip.riderRated = true;
                        } else {
                          trip.driverRated = true;
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: _isRated() == false
                ? () => _rateUserDialog(context, trip)
                : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).disabledColor,
            ),
            child: const Text("Rate"),
          ),
        )
      ],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: ImageFrame(
                      firebaseUid: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow("📍 Start Location:", widget.trip.startLocation),
                _buildInfoRow("🎯 Destination:", widget.trip.destination),
                const SizedBox(height: 15),
                _buildInfoRow("👤 Driver:",
                    widget.trip.driver?.name ?? SingleUser().getUser()!.name),
                _buildInfoRow("🚗 Car:",
                    "${widget.trip.driver?.carMake ?? SingleUser().getUser()!.carMake} ${widget.trip.driver?.carModel ?? SingleUser().getUser()!.carModel}"),
                const SizedBox(height: 15),
                if (widget.trip.driverId == SingleUser().getUser()!.id)
                  Column(
                    children: [
                      _buildInfoRow(
                          "💰 You made:", "\$${widget.trip.driverPayout}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "🚘 You Drove:",
                            style: GoogleFonts.fredoka(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          ClipOval(
                            child: ImageFrame(
                              firebaseUid: widget.trip.rider!.firebaseUid!,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (widget.trip.driverId != SingleUser().getUser()!.id)
                  _buildInfoRow(
                      "💳 This ride cost you:", "\$${widget.trip.riderCost}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.fredoka(fontSize: 18, color: Colors.black),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
