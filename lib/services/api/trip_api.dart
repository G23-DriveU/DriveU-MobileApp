import 'dart:convert';
import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripApi {
  Future<Set<Marker>> getTrips(Map<String, String> queryParameters,
      BuildContext context, Function showTripInfo) async {
    try {
      final response = await SingleClient()
          .get(TRIP_BY_RADIUS, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        return items.map((item) {
          final trip = FutureTrip.fromJson(item);
          return Marker(
            markerId: MarkerId(trip.id.toString()),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(trip.destinationLat, trip.destinationLng),
            onTap: () => showTripInfo(context, trip),
          );
        }).toSet();
      } else {
        print("Failed to load any trips.");
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<List<PastTrip>> getPreviousTrips(
      Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().get(PAST_TRIP, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<PastTrip> riderTrips =
            pastTripsFromJson(jsonEncode(data['riderTrips']));
        List<PastTrip> driverTrips =
            pastTripsFromJson(jsonEncode(data['driverTrips']));

        return riderTrips + driverTrips;
      }
      throw Error();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<void> createRideRequest(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .post(CREATE_RIDE_REQUEST, queryParameters: queryParameters);

      if (response.statusCode == 200) {
      } else {
        throw Exception(["Failed to make a request"]);
      }
    } catch (e) {
      return;
    }
  }
}
