import 'package:flutter/material.dart';
import 'package:push_handler/main.dart';
import 'package:stream_value/core/stream_value.dart';

class PushWidgetController {
  final MessageData messageData;
  final GlobalKey<NavigatorState> navigatorKey;
  late TabController tabController;

  final isLastTabStreamValue = StreamValue<bool>(defaultValue: false);
  final currentIndexStreamValue = StreamValue<int>(defaultValue: 0);

  PushWidgetController({required this.messageData, required this.navigatorKey});

  void toNext() {
    tabController.animateTo(tabController.index + 1);
  }

  void toPrevious() {
    tabController.animateTo(tabController.index - 1);
  }

  dispose(){
    tabController.dispose();
  }
}