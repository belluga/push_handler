import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

abstract class PushWidget extends StatefulWidget {
  final MessageData messageData;
  final GlobalKey<NavigatorState> navigatorKey;
  final Function()? onTapExpand ;

  const PushWidget(
      {super.key, required this.messageData, required this.navigatorKey, this.onTapExpand});

  @override
  State<PushWidget> createState();
}

abstract class PushWidgetState extends State<PushWidget>
    with TickerProviderStateMixin {
  late PushWidgetController controller;

  @override
  void initState() {
    super.initState();
    controller = PushWidgetController(
      messageData: widget.messageData,
      navigatorKey: widget.navigatorKey,
    );
    controller.tabController = TabController(
      length: widget.messageData.steps.length,
      initialIndex: controller.currentIndexStreamValue.value,
      vsync: this,
    );

    controller.tabController.addListener(_listenTabController);
  }

  @override
  Widget build(BuildContext context);

  void _listenTabController() {
    final bool _currentIsLastTabStatus = controller.tabController.index + 1 >=
        controller.messageData.steps.length;

    final int _currentIndex = controller.tabController.index;

    if (_currentIndex != controller.currentIndexStreamValue.value) {
      setState(() {
        controller.isLastTabStreamValue.addValue(_currentIsLastTabStatus);
        controller.currentIndexStreamValue
            .addValue(controller.tabController.index);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
