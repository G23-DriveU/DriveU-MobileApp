// User singleton class to hold the state of the current user globally
import 'package:driveu_mobile_app/model/app_user.dart';

class SingleUser {
  static final SingleUser _instance = SingleUser._internal();
  // Return the singleton user
  factory SingleUser() => _instance;
  // Private constructor
  SingleUser._internal();
  // Our global instance of our user
  AppUser? _user;

  void setUser(AppUser user) {
    _user = user;
  }

  AppUser? getUser() {
    return _user;
  }
}
