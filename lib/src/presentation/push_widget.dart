import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

abstract class PushWidget extends StatefulWidget {
  final MessageData messageData;
  final Function()? onTapExpand ;
  final PushNavigationResolver? navigationResolver;
  final ValueChanged<int>? onStepChanged;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;

  const PushWidget(
      {super.key,
      required this.messageData,
      this.onTapExpand,
      this.navigationResolver,
      this.onStepChanged,
      this.onButtonPressed});

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
    );
    controller.navigationResolver = widget.navigationResolver;
    controller.tabController = TabController(
      length: widget.messageData.steps.length,
      initialIndex: controller.currentIndexStreamValue.value,
      vsync: this,
    );

    _updateTabState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepChanged?.call(controller.currentIndexStreamValue.value);
    });
    controller.tabController.addListener(_listenTabController);
  }

  @override
  Widget build(BuildContext context);

  void _listenTabController() {
    _updateTabState();
  }

  void _updateTabState() {
    final stepsLength = controller.messageData.steps.length;
    final currentIndex = controller.tabController.index;
    final isLast = stepsLength == 0 || currentIndex + 1 >= stepsLength;

    if (currentIndex != controller.currentIndexStreamValue.value ||
        isLast != controller.isLastTabStreamValue.value) {
      setState(() {
        controller.isLastTabStreamValue.addValue(isLast);
        controller.currentIndexStreamValue.addValue(currentIndex);
      });
      widget.onStepChanged?.call(currentIndex);
    }
  }


  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
