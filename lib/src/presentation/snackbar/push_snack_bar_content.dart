import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_widget.dart';
import 'package:push_handler/src/presentation/widgets/push_bottom_buttons.dart';
import 'package:push_handler/src/presentation/widgets/push_step_content.dart';
import 'package:push_handler/src/presentation/widgets/push_top_bar.dart';

class PushSnackBarContent extends PushWidget {
  const PushSnackBarContent(
      {super.key, required super.messageData, required super.navigatorKey});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).colorScheme.primary,
      child: Text(controller.messageData.title.value),
    );
  }
}
