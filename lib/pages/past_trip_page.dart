import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

class PastTripPage extends StatefulWidget {
  final PastTrip trip;
  final LocationData? userPosition;
  const PastTripPage({super.key, required this.trip, required this.userPosition});

  @override
  State<PastTripPage> createState() => _PastTripPageState();
}

class _PastTripPageState extends State<PastTripPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
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
                _buildInfoRow("👤 Driver:", widget.trip.driver?.name ?? SingleUser().getUser()!.name),
                _buildInfoRow("🚗 Car:", "${widget.trip.driver?.carMake ?? SingleUser().getUser()!.carMake} ${widget.trip.driver?.carModel ?? SingleUser().getUser()!.carModel}"),
                const SizedBox(height: 15),
                if (widget.trip.driverId == SingleUser().getUser()!.id)
                  Column(
                    children: [
                      _buildInfoRow("💰 You made:", "\$${widget.trip.driverPayout}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "🚘 You Drove:",
                            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold),
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
                  _buildInfoRow("💳 This ride cost you:", "\$${widget.trip.riderCost}"),
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
