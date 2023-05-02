import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/message_data.dart';
import 'package:push_handler/src/infrastructure/services/fcm_service.dart';
import 'package:stream_value/core/stream_value.dart';

class PushHandler {
  final Future<void> Function(RemoteMessage) onbackgroundStartMessage;

  PushHandler({
    required this.onbackgroundStartMessage,
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

  static Future<String> getToken() async =>
      Future.value(await FCMService.getToken());

  static Future<void> requestPermission() async =>
      await FCMService.requestPermission();

  final messageStreamValue = StreamValue<MessageData?>(defaultValue: null);

  void _onMessage(RemoteMessage messageReceived) {
    final pushDataMessage = MessageData.fromMap(messageReceived.data);
    messageStreamValue.addValue(pushDataMessage);
  }

  void _onMessageOpenedApp(RemoteMessage messageReceived) =>
      _onMessage(messageReceived);

  static Future<void> onBackgroundMessage(
      RemoteMessage messageReceived) async {}
}
