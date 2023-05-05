import 'package:flutter/material.dart';
import 'package:push_handler/main.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_bottom_buttons.dart';
import 'package:push_handler/src/presentation/widgets/push_step_content.dart';
import 'package:push_handler/src/presentation/widgets/push_top_bar.dart';

class PushStepDialog extends StatelessWidget {
  final PushWidgetController controller;

  const PushStepDialog({super.key, required this.controller});

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
              PushTopBar(controller: controller),
              PushStepContent(stepData: _stepData),
              PushBottomButtons(controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}
