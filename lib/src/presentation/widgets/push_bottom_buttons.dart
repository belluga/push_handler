import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_buttons_area.dart';

class PushBottomButtons extends StatelessWidget {
  final PushWidgetController controller;

  const PushBottomButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.isLastTabStreamValue.value == false
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: controller.toNext,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          )
        : PushActionButtonsArea(
            controller: controller,
            buttonDataList: controller.messageData.buttons,
          );
  }
}
