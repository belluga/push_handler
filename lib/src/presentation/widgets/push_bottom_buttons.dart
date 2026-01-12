import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_buttons_area.dart';
import 'package:push_handler/src/presentation/widgets/push_action_button.dart';
class PushBottomButtons extends StatelessWidget {
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;
  final Future<void> Function(ButtonData button, StepData step)? onCustomAction;

  const PushBottomButtons({
    super.key,
    required this.controller,
    this.onButtonPressed,
    this.onCustomAction,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = controller.currentIndexStreamValue.value;
    final isLastStep = controller.isLastStep;
    final step = controller.currentStep;
    final stepButtons = step?.buttons ?? const [];
    final hasStepButtons = stepButtons.isNotEmpty;
    final hasGlobalButtons =
        controller.messageData.buttons.isNotEmpty && isLastStep;
    final isQuestion =
        step?.type == 'question' || step?.type == 'selector';
    final shouldShowDefaultContinue = !hasStepButtons && !hasGlobalButtons;
    final canAdvance = controller.canAdvanceStreamValue.value;
    final canSubmit = controller.canSubmitStreamValue.value;
    final closeBehavior = controller.messageData.closeBehavior.value;
    final shouldCloseAfterAction =
        isLastStep && closeBehavior == MessageCloseBehavior.after_action;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasStepButtons)
          PushActionButtonsArea(
            controller: controller,
            buttonDataList: stepButtons,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            closeOnTap: shouldCloseAfterAction,
          )
        else if (hasGlobalButtons)
          PushActionButtonsArea(
            controller: controller,
            buttonDataList: controller.messageData.buttons,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            closeOnTap: shouldCloseAfterAction,
          )
        else if (shouldShowDefaultContinue)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: canAdvance && (!isQuestion || canSubmit)
                    ? () async {
                        if (isQuestion && controller.primaryAction != null) {
                          await controller.primaryAction!.call();
                          return;
                        }
                        if (isLastStep) {
                          if (shouldCloseAfterAction) {
                            controller.requestClose();
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          return;
                        }
                        await controller.toNext();
                      }
                    : null,
                style: PushActionButton.primaryStyle(context),
                child: const Text('Continuar'),
              ),
            ),
          ),
      ],
    );
  }
}
