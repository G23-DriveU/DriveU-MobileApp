import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  // Create an instance of Firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  // Function to initialize notifications
  Future<void> initNotifications() async {
    // Request permissions from the user
    await _firebaseMessaging.requestPermission();

    // Fetch FCM token from the device (needed to send notifications)
    final fcmToken = await _firebaseMessaging.getToken();
    print("DEBUG FCM: $fcmToken");
    SingleUser().getUser()?.fcmToken = fcmToken;

    // Initialize the push notification
    initPushNotifications();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initLocalNotifications();
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> initLocalNotifications() async {
    // Initialize the plugin. app_icon needs to be added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) => null,
    // );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            // iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // On tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("DEBUG: Seeing message");
    // navigatorKey.currentState!
    //     .pushNamed("/message", arguments: notificationResponse);
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // There is no message
    if (message == null) return;
    // Navigate to other screen if user taps the message
    // navigatorKey.currentState
    //     ?.pushNamed('/notification_screen', arguments: message);
    print("DEBUG: Message received");
  }

  // Foreground and background settings
  Future<void> initPushNotifications() async {
    // Handle notifications if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // Attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              // 'your_channel_description',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
            ),
          ),
        );
      }
    });
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(
      'Title: ${message.notification?.title}\nBody ${message.notification?.body}');
}
