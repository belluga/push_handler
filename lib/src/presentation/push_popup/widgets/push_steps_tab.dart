import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_step_dialog.dart';

class PushStepsTab extends StatelessWidget {
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;

  const PushStepsTab({
    super.key,
    required this.controller,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        controller.messageData.steps.length,
        (index) => PushStepDialog(
          controller: controller,
          onButtonPressed: onButtonPressed,
        ),
      ),
    );
  }
}
