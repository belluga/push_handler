import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_steps_tab.dart';
import 'package:push_handler/src/presentation/push_widget.dart';

class PushPopup extends PushWidget {
  const PushPopup({super.key, required super.messageData, required super.navigatorKey});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    return PushStepsTab(
      controller: controller,
    );
  }
}
