import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/past_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      Map<String, String> queryParameters) async {
    // Dynamically determine which trips to get, if the user is a rider, then get rider and vis. versa.
    try {
      final response = await SingleClient()
          .get(FUTURE_TRIPS_DRIVER, queryParameters: queryParameters);

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

  // Return a list of ride requests for a rider. This will be used
  // to display their future trips (both "pending" and "accepted")
  Future<List<RideRequest>> getRiderFutureTrips(
      Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .get(RIDE_REQUEST_RIDER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return rideRequestsFromJson(jsonEncode(data['items']));
      } else {
        throw Exception();
      }
    } catch (e) {
      return [];
    }
  }

  Future<FutureTrip?> createTrip(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .post(FUTURE_TRIPS_CRUD, queryParameters: queryParameters);

      if (response.statusCode == 201) {
        return FutureTrip.fromJson(jsonDecode(response.body)["item"]);
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e.toString());
      return null;
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

  Future<List<RideRequest>> getRideRequests(
      Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .get(RIDE_REQUEST_DRIVER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return rideRequestsFromJson(jsonEncode(data['items']));
      } else {
        throw Exception();
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> acceptRideRequest(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .put(ACCEPT_RIDE_REQUEST, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> rejectRideRequest(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .delete(REJECT_RIDE_REQUEST, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> startTrip(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .put(START_TRIP, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Error starting trip");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> startSecondLeg(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .put(LEAVE_DESITNATION, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Error starting second leg of trip");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> pickUpRider(Map<String, String> queryParameters) async {
    try {
      await SingleClient().put(PICK_UP_RIDER, queryParameters: queryParameters);
    } catch (e) {
      print("Error $e");
    }
  }

  Future<FutureTrip?> getFutureTrip(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .get(GET_FUTURE_TRIP, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FutureTrip.fromJson(data['futureTrip']);
      } else {
        throw Exception();
      }
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  Future<int> reachDestination(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .put(REACH_DESTINATION, queryParameters: queryParameters);

      if (response.statusCode == 201) {
        return 200;
      } else {
        throw Exception("Error stopping trips.");
      }
    } catch (e) {
      print(e);
      return 500;
    }
  }

  Future<int> dropOffRider(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .put(DROP_OFF_RIDER, queryParameters: queryParameters);
      if (response.statusCode == 201) {
        return 200;
      } else {
        throw Exception("Error dropping off rider");
      }
    } catch (e) {
      return 500;
    }
  }

  // Enables riders/drivers to rate each other. 'rater' represents who is doing
  // the rating; ie. if a rider is rating then they will be rating a driver etc.
  Future<int> rateUser(
      Map<String, String> queryParameters, String ratee) async {
    // If the user is a rider, then we want to rate the driver and vis versa.
    String path = ratee == "rider" ? RATE_RIDER : RATE_DRIVER;
    try {
      final response =
          await SingleClient().put(path, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return 200;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print("There was an error rating a user $e");
      return 500;
    }
  }

  // Cancel a ride request for a rider
  Future<void> cancelRideRequest(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .delete(DELETE_RIDE_REQUEST_RIDER, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Could not delete ride request");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTrip(Map<String, String> queryParameters) async {
    try {
      final response = await SingleClient()
          .delete(FUTURE_TRIPS_CRUD, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Could not delete trip");
      }
    } catch (e) {
      print(e);
    }
  }
}
