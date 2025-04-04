// Standard helper functions that are needed across the whole application
// Calculate the distance between two locations
import 'dart:math';

import 'package:driveu_mobile_app/model/future_trip.dart';
import 'package:driveu_mobile_app/model/ride_request.dart';
import 'package:driveu_mobile_app/pages/rides_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers
  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

int getSecondsSinceEpoch() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

TripStage getTripStage(FutureTrip? trip, RideRequest? request) {
  // A driver calling this
  if (trip != null) {
    if (trip.request != null) {
      return getStage(trip.request!.status);
    } else {
      return TripStage.notStarted;
    }
  }
  // A rider is calling this
  else {
    return getStage(request!.status);
  }
}

TripStage getStage(String status) {
  switch (status) {
    case "pending":
    case "accepted":
      return TripStage.notStarted;
    case "started":
      return TripStage.startedFirstLeg;
    case "picked up":
      return TripStage.pickedUp;
    case "at destination":
      return TripStage.endFirstLeg;
    case "left destination":
      return TripStage.startSecondLeg;
    default:
      return TripStage.tripEnd;
  }
}

// If it is not one of these two status, then the trip has started.
bool isStarted(TripStage status) {
  return status != TripStage.notStarted;
}
