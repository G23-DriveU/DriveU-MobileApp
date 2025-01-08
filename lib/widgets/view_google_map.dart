import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewGoogleMap extends StatefulWidget {
  const ViewGoogleMap({super.key});

  @override
  State<ViewGoogleMap> createState() => _ViewGoogleMapState();
}

class _ViewGoogleMapState extends State<ViewGoogleMap> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(0, 0))));
  }
}
