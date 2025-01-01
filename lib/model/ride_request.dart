import 'dart:convert';
import 'package:driveu_mobile_app/model/app_user.dart';

// Get a single ride request
RideRequest rideRequestFromJson(String str) =>
    RideRequest.fromJson(json.decode(str));
String rideRequestToJson(RideRequest data) => json.encode(data.toJson());
// Get a list of ride requests
List<RideRequest> rideRequestsFromJson(String str) => List<RideRequest>.from(
    json.decode(str).map((x) => RideRequest.fromJson(x)));
String rideRequestsToJson(List<RideRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// https://app.quicktype.io/ was used to generate the model class from the JSON response
class RideRequest {
  int futureTripId;
  int riderId;
  String riderLocation;
  String status;
  String authorizationId;
  bool roundTrip;
  int id;
  double riderLocationLat;
  double riderLocationLng;
  String pickupTime;
  String eta;
  double riderCost;
  double driverPayout;
  double distance;
  String dropoffTime;
  AppUser rider;

  RideRequest({
    required this.futureTripId,
    required this.riderId,
    required this.riderLocation,
    required this.status,
    required this.authorizationId,
    required this.roundTrip,
    required this.id,
    required this.riderLocationLat,
    required this.riderLocationLng,
    required this.pickupTime,
    required this.eta,
    required this.riderCost,
    required this.driverPayout,
    required this.distance,
    required this.dropoffTime,
    required this.rider,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) => RideRequest(
        futureTripId: json["futureTripId"],
        riderId: json["riderId"],
        riderLocation: json["riderLocation"],
        status: json["status"],
        authorizationId: json["authorizationId"],
        roundTrip: json["roundTrip"],
        id: json["id"],
        riderLocationLat: json["riderLocationLat"]?.toDouble(),
        riderLocationLng: json["riderLocationLng"]?.toDouble(),
        pickupTime: json["pickupTime"],
        eta: json["eta"],
        riderCost: json["riderCost"]?.toDouble(),
        driverPayout: json["driverPayout"]?.toDouble(),
        distance: json["distance"]?.toDouble(),
        dropoffTime: json["dropoffTime"],
        rider: AppUser.fromJson(json["rider"]),
      );

  Map<String, dynamic> toJson() => {
        "futureTripId": futureTripId,
        "riderId": riderId,
        "riderLocation": riderLocation,
        "status": status,
        "authorizationId": authorizationId,
        "roundTrip": roundTrip,
        "id": id,
        "riderLocationLat": riderLocationLat,
        "riderLocationLng": riderLocationLng,
        "pickupTime": pickupTime,
        "eta": eta,
        "riderCost": riderCost,
        "driverPayout": driverPayout,
        "distance": distance,
        "dropoffTime": dropoffTime,
        // TODO: will this cause a problem?
        "rider": rider.toJson(),
      };
}
