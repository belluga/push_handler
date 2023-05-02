import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/push_popup/push_popup.dart';

class PushHandlerRepository {
  final Future<void> Function(RemoteMessage) onBackgroundMessage;
  final globalNavigatorKey = GlobalKey<NavigatorState>();
  late PushHandler pushHandler;

  PushHandlerRepository(this.onBackgroundMessage);

  Future<void> init() async {
    pushHandler = PushHandler(onbackgroundStartMessage: onBackgroundMessage);
    await pushHandler.init();
    pushHandler.messageStreamValue.stream.listen(_processMessage);
  }

  void _processMessage(MessageData? newMessage) {
    if (newMessage == null) {
      return;
    }

    switch (newMessage.layoutType.value) {
      case MessageLayoutType.popup:
        return processPoppup(newMessage);
      case MessageLayoutType.dialogFull:
        return processDialogFull(newMessage);
      case MessageLayoutType.bottomModal:
        return processBottomModal(newMessage);
      case MessageLayoutType.actionButton:
        return processActionButton(newMessage);
      case MessageLayoutType.snackBar:
        return processSnackBar(newMessage);
    }
  }

  void processPoppup(MessageData messageData) => showDialog(
        context: globalNavigatorKey.currentContext!,
        builder: (context) {
          return PushPopup(messageData: messageData);
        },
      );

  void processDialogFull(MessageData messageData) => processPoppup(messageData);
  void processBottomModal(MessageData messageData) =>
      processPoppup(messageData);
  void processActionButton(MessageData messageData) =>
      processPoppup(messageData);
  void processSnackBar(MessageData messageData) => processPoppup(messageData);
}
