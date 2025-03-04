import 'dart:convert';
// import 'package:flutter_application_openmapapp/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsUtils {
  // Get location suggestions from Google Maps API
  Future<List<Map<String, dynamic>>> getLocations(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';

    final response = await http.get(Uri.parse(url));
    // We got a response
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      final predictions = jsonResponse['predictions'] as List;
      // Return the list of place names and their IDs
      return predictions
          .map((prediction) => {
                'description': prediction['description'],
                'place_id': prediction['place_id'],
              })
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  // Get location details (Lat and Lng) from Google Maps API
  Future<LatLng?> getLocationDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = jsonResponse['result'];

      if (result != null) {
        final location = result['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {}
    } else {
      print('Failed to load location details: ${response.statusCode}');
      return null;
    }
    return null;
  }

  // Take in the LatLng for start and end points and open up Google Maps with that route selected
  Future<void> launchMaps(
      String startLat, String startLng, String endLat, String endLng) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');

    // Check if the URL can be launched
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  // Given a set of LatLngs generate the polylines for the route the driver
  // will need to take in order to get to the rider and the destination.
  Future<PolylineResult> getPolylines(Map<String, LatLng> points) async {
    return await PolylinePoints().getRouteBetweenCoordinates(
      googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
      request: PolylineRequest(
          origin: PointLatLng(
              points["origin"]!.latitude, points["origin"]!.longitude),
          destination: PointLatLng(points["destination"]!.latitude,
              points["destination"]!.longitude),
          mode: TravelMode.driving,
          wayPoints: [
            PolylineWayPoint(
                location:
                    "${points["waypoint"]!.latitude},${points["waypoint"]!.longitude}")
          ]),
    );
  }
}
