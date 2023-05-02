import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

abstract class PushHandlerRepositoryContract {
  final Future<void> Function(RemoteMessage) onBackgroundMessage;
  GlobalKey<NavigatorState> get globalNavigatorKey;
  late PushHandler pushHandler;

  PushHandlerRepositoryContract(this.onBackgroundMessage);

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

  void processPoppup(MessageData messageData);
  void processDialogFull(MessageData messageData);
  void processBottomModal(MessageData messageData);
  void processActionButton(MessageData messageData);
  void processSnackBar(MessageData messageData);
}
