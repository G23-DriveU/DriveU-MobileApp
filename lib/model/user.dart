import 'dart:convert';

// NOTE: Firebase uid and FCM tokens are set to null since they are not immediately
// received upon the user registering first with Firebase. Because of this, they are
// delayed in getting them until we can ping Firebase for those things.

// Get a singular user
User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User data) => json.encode(data.toJson());
// To get Users from a list
List<User> usersFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));
String usersToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// https://app.quicktype.io/ was used to generate the model class from the JSON response
class User {
  String? firebaseUid;
  dynamic profileImage;
  String name;
  String email;
  String phoneNumber;
  String school;
  String? fcmToken;
  bool driver;
  // Note that if the user IN NOT driving then capturing this information in the database is not necessary
  int? id;
  int? driverRating;
  int? driverReviewCount;
  int? riderRating;
  int? riderReviewCount;
  String? carColor;
  String? carPlate;
  String? carMake;
  String? carModel;
  int? carMpg;

  User({
    this.firebaseUid,
    required this.profileImage,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.school,
    this.fcmToken,
    required this.driver,
    this.id,
    this.driverRating,
    this.driverReviewCount,
    this.riderRating,
    this.riderReviewCount,
    this.carColor,
    this.carPlate,
    this.carMake,
    this.carModel,
    this.carMpg,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        firebaseUid: json["firebaseUid"],
        profileImage: json["profileImage"],
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        school: json["school"],
        fcmToken: json["fcmToken"],
        driver: json["driver"],
        id: json["id"],
        driverRating: json["driverRating"],
        driverReviewCount: json["driverReviewCount"],
        riderRating: json["riderRating"],
        riderReviewCount: json["riderReviewCount"],
        carColor: json["carColor"],
        carPlate: json["carPlate"],
        carMake: json["carMake"],
        carModel: json["carModel"],
        carMpg: json["carMpg"],
      );

  Map<String, dynamic> toJson() => {
        "firebaseUid": firebaseUid,
        "profileImage": profileImage,
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "school": school,
        "fcmToken": fcmToken,
        "driver": driver,
        "id": id,
        "driverRating": driverRating,
        "driverReviewCount": driverReviewCount,
        "riderRating": riderRating,
        "riderReviewCount": riderReviewCount,
        "carColor": carColor,
        "carPlate": carPlate,
        "carMake": carMake,
        "carModel": carModel,
        "carMpg": carMpg,
      };
}
