import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<RemoteMessage?> getInitialMessage() async =>
      await messaging.getInitialMessage();

  static Future<String> getToken() async =>
      Future.value(await messaging.getToken());

  static Future<void> requestPermission() async {
    await FCMService.messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
