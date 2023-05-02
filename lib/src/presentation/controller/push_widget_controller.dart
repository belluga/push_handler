import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

class PushWidgetController {
  final MessageData messageData;
  late TabController tabController;

  PushWidgetController({required this.messageData});

  dispose(){
    tabController.dispose();
  }
}