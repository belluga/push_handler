import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:stream_value/core/stream_value.dart';

class PushWidgetController {
  final MessageData messageData;
  late TabController tabController;

  final isLastTabStreamValue = StreamValue<bool>(defaultValue: false);
  final currentIndexStreamValue = StreamValue<int>(defaultValue: 0);

  PushWidgetController({required this.messageData});

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