import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:driveu_mobile_app/constants/api_path.dart';
import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/services/api/single_client.dart';

class UserApi {
  // Create a new user to the application
  Future<String?> createUser(Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().post(USER, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        return null;
      } else {
        return response.body;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> sendProfileImage(String firebaseUid, String base64Image) async {
    var res = await http.post(
      Uri.parse(
          'https://driveu-backend-bkdme7g5ctgmdjgb.eastus2-01.azurewebsites.net/profilePic'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firebaseUid': firebaseUid,
        'profilePic': base64Image,
      }),
    );

    if (res.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Image upload failed');
    }
  }

  // For existing users, retrieve their user data from the database
  static Future<AppUser?> getUser(Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().get(USER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return userFromJson(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> editUserInfo(Map<String, String> queryParameters) async {
    try {
      final response =
          await SingleClient().put(USER, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Error Editing info");
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
