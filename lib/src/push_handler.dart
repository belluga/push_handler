import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_handler/src/infrastructure/services/fcm_service.dart';
import 'package:stream_value/core/stream_value.dart';

class PushHandler {
  final Future<void> Function(RemoteMessage) onbackgroundStartMessage;
  final Future<void> Function(RemoteMessage)? onMessage;
  final Future<void> Function(RemoteMessage)? onMessageOpenedApp;

  PushHandler({
    required this.onbackgroundStartMessage,
    this.onMessage,
    this.onMessageOpenedApp,
  });

  Future<void> init() async {
    final RemoteMessage? _initialMessage = await FCMService.getInitialMessage();

    if (_initialMessage != null) {
      _onMessageOpenedApp(_initialMessage);
    }

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(onbackgroundStartMessage);
  }

  static Future<String?> getToken() async => FCMService.getToken();

  static Future<void> requestPermission() async =>
      await FCMService.requestPermission();

  final messageStreamValue = StreamValue<RemoteMessage?>();

  void _onMessage(RemoteMessage messageReceived) {
    messageStreamValue.addValue(messageReceived);
    final handler = onMessage;
    if (handler != null) {
      unawaited(handler(messageReceived));
    }
  }

  void _onMessageOpenedApp(RemoteMessage messageReceived) {
    _onMessage(messageReceived);
    final handler = onMessageOpenedApp;
    if (handler != null) {
      unawaited(handler(messageReceived));
    }
  }

  static Future<void> onBackgroundMessage(
      RemoteMessage messageReceived) async {}
}
