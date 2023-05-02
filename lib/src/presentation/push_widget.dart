import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

abstract class PushWidget extends StatefulWidget {
  final MessageData messageData;

  const PushWidget({super.key, required this.messageData});

  @override
  State<PushWidget> createState();
}

abstract class PushWidgetState extends State<PushWidget>
    with TickerProviderStateMixin {
  late PushWidgetController controller;
  bool isLastTab = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PushWidgetController(messageData: widget.messageData);
    controller.tabController = TabController(
      length: widget.messageData.steps.length,
      initialIndex: currentIndex,
      vsync: this,
    );

    controller.tabController.addListener(_listenTabController);
  }

  @override
  Widget build(BuildContext context);

  void toNext() {
    controller.tabController.animateTo(controller.tabController.index + 1);
  }

  void toPrevious() {
    controller.tabController.animateTo(controller.tabController.index - 1);
  }

  void _listenTabController() {
    final bool _currentIsLastTabStatus = controller.tabController.index + 1 >=
        controller.messageData.steps.length;

    final int _currentIndex = controller.tabController.index;

    if (_currentIndex != currentIndex) {
      setState(() {
        isLastTab = _currentIsLastTabStatus;
        currentIndex = controller.tabController.index;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
