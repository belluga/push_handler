import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_action_buttons_area.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_dismiss_button.dart';

class PushStepContent extends StatelessWidget {
  final PushWidgetController controller;

  const PushStepContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final StepData _stepData =
        controller.messageData.steps[controller.currentIndexStreamValue.value];

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.messageData.allowDismiss.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        PushDismissButton(),
                      ],
                    )
                  : const SizedBox(
                      height: 26,
                    ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _stepData.content.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLastTabStreamValue.value == false)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.currentIndexStreamValue.value != 0)
                      IconButton(
                        onPressed: controller.toPrevious,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    IconButton(
                      onPressed: controller.toNext,
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              if (controller.isLastTabStreamValue.value == true)
                PushActionButtonsArea(
                  buttonDataList: controller.messageData.buttons,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
