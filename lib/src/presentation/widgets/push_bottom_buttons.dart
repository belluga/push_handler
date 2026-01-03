import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_buttons_area.dart';
import 'package:push_handler/src/presentation/widgets/push_dismiss_button.dart';

class PushBottomButtons extends StatelessWidget {
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;

  const PushBottomButtons({
    super.key,
    required this.controller,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = controller.isLastTabStreamValue.value == true;
    final hasActions = controller.messageData.buttons.isNotEmpty;
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
        : hasActions
            ? PushActionButtonsArea(
                controller: controller,
                buttonDataList: controller.messageData.buttons,
                onButtonPressed: onButtonPressed,
              )
            : PushDismissButton(useCloseIcon: isLastStep);
  }
}
