import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
// Create an instance of Firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize notifications
  Future<void> initNotifications() async {
    // Request permissions from the user
    await _firebaseMessaging.requestPermission();

    // fetch FCM token from the device (needed to send notifications)
    final fcmToken = await _firebaseMessaging.getToken();
    SingleUser().getUser()?.fcmToken = fcmToken;
    // TODO: Might remove this
    print('token: ${fcmToken.toString()}');
    // initialize the push notification
    // initPushNotifications();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // function to handle received messages
  // void handleMessage(RemoteMessage? message) {
  //   // There is no message
  //   if (message == null) return;
  //   // Navigate to other screen if user taps the message
  //   navigatorKey.currentState
  //       ?.pushNamed('/notification_screen', arguments: message);
  // }

  // Foreground and background settings
  // Future initPushNotifications() async {
  //   // Handle notifications if the app was terminated and now opened
  //   FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  //   // Attach event listeners for when a notification opens the app
  //   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  // }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(
      'Title: ${message.notification?.title}\nBody ${message.notification?.body}');
}
