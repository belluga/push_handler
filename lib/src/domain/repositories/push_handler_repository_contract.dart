import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/modal_bottom_sheet/modal_bottom_sheet_content.dart';
import 'package:push_handler/src/presentation/push_popup/push_popup.dart';
import 'package:push_handler/src/presentation/push_screen_full/push_screen_full.dart';
import 'package:push_handler/src/presentation/snackbar/push_snack_bar_content.dart';

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

  void _processOnClickType(MessageData messageData) {
    {
      final MessageLayoutType? _onClickType =
          messageData.onClicklayoutType?.value;

      if (_onClickType == null) {
        return;
      }

      Navigator.of(globalNavigatorKey.currentContext!).pop();

      _processMessage(messageData);
    }
  }

  void _processMessage(MessageData? newMessage) {
    if (newMessage == null) {
      return;
    }

    switch (newMessage.layoutType.value) {
      case MessageLayoutType.popup:
        return processPoppup(newMessage);
      case MessageLayoutType.fullScreen:
        return processDialogFull(newMessage);
      case MessageLayoutType.bottomModal:
        return processBottomModal(newMessage);
      case MessageLayoutType.actionButton:
        return processActionButton(newMessage);
      case MessageLayoutType.snackBar:
        return processSnackBar(newMessage);
    }
  }

  void processPoppup(MessageData messageData) {
    showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (context) {
        return PushPopup(
          messageData: messageData,
          navigatorKey: globalNavigatorKey,
        );
      },
    );
  }

  void processDialogFull(MessageData messageData) {
    showGeneralDialog(
      context: globalNavigatorKey.currentContext!,
      pageBuilder: (context, _, __) => PushScreenFull(
        navigatorKey: globalNavigatorKey,
        messageData: messageData,
      ),
    );
  }

  void processBottomModal(MessageData messageData) {
    showModalBottomSheet(
      context: globalNavigatorKey.currentContext!,
      isDismissible: messageData.allowDismiss.value,
      backgroundColor: Colors.transparent,
      builder: (context) => InkWell(
        onTap: () => _processOnClickType(messageData),
        child: PushModalBottomSheetContent(
          messageData: messageData,
          navigatorKey: globalNavigatorKey,
          onTapExpand: () => processDialogFull(messageData),
        ),
      ),
    );
  }

  void processSnackBar(MessageData messageData) {
    try {
      ScaffoldMessenger.of(globalNavigatorKey.currentContext!).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          dismissDirection: DismissDirection.horizontal,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: InkWell(
            onTap: () => _processOnClickType(messageData),
            child: PushSnackBarContent(
              messageData: messageData,
              navigatorKey: globalNavigatorKey,
              onTapExpand: () => processDialogFull(messageData),
            ),
          ),
        ),
      );
    } catch (e) {
      _processOnClickType(messageData);
    }
  }

  void processActionButton(MessageData messageData) =>
      processSnackBar(messageData);
}
