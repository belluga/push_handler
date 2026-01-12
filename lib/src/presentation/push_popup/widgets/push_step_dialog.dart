import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_bottom_buttons.dart';
import 'package:push_handler/src/presentation/widgets/push_step_content.dart';
import 'package:push_handler/src/presentation/widgets/push_top_bar.dart';

class PushStepDialog extends StatelessWidget {
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;
  final Future<void> Function(ButtonData button, StepData step)? onCustomAction;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;
  final String? Function(StepData step, String? value)? stepValidator;

  const PushStepDialog({
    super.key,
    required this.controller,
    this.onButtonPressed,
    this.onCustomAction,
    this.optionsBuilder,
    this.onStepSubmit,
    this.stepValidator,
  });

  @override
  Widget build(BuildContext context) {
    final StepData _stepData =
        controller.messageData.steps[controller.currentIndexStreamValue.value];

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Dialog(
        backgroundColor: controller.resolveBackgroundColor(context),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PushTopBar(controller: controller),
                PushStepContent(
                  stepData: _stepData,
                  controller: controller,
                  optionsBuilder: optionsBuilder,
                  onStepSubmit: onStepSubmit,
                  stepValidator: stepValidator,
                ),
                PushBottomButtons(
                  controller: controller,
                  onButtonPressed: onButtonPressed,
                  onCustomAction: onCustomAction,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
