// User singleton class to hold the state of the current user globally
import 'package:driveu_mobile_app/model/user.dart';

class SingleUser {
  static final SingleUser _instance = SingleUser._internal();
  // Return the singleton user
  factory SingleUser() => _instance;
  // Private constructor
  SingleUser._internal();
  // Our global instance of our user
  User? _user;

  void setUser(User user) {
    _user = user;
  }

  User? getUser() {
    return _user;
  }
}
