import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessages {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permissions for iOS devices
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Print the token for debugging
    String? token = await getToken();
    print('FCM Token: $token');

    // Set up foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}');
      print('Message body: ${message.notification?.body}');
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Get the FCM token for the device
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
