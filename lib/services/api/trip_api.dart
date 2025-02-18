import 'dart:convert';
import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class TripApi {
  Future<Set<Marker>> getTrips(Map<String, String> queryParameters,
      BuildContext context, Function showTripInfo) async {
    String endPoint =
        SingleUser().getUser()!.driver ? FUTURE_TRIPS_DRIVER : TRIP_BY_RADIUS;
    try {
      final response =
          await SingleClient().get(endPoint, queryParameters: queryParameters);
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

  Future<List<FutureTrip>> getFutureTrips(
      Map<String, String> queryParameters, String type) async {
    // Dynamically determine which trips to get, if the user is a rider, then get rider and vis. versa.
    String getTrip = type == 'rider' ? FUTURE_TRIPS_RIDER : FUTURE_TRIPS_DRIVER;
    try {
      final response =
          await SingleClient().get(getTrip, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<FutureTrip> futureTripsDriver =
            futureTripsFromJson(jsonEncode(data['items']));
        return futureTripsDriver;
      } else {
        throw Exception();
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> createTrip(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .post(FUTURE_TRIPS_CRUD, queryParameters: queryParameters);

      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e.toString());
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
