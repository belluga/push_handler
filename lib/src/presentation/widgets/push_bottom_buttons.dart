import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_buttons_area.dart';
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
    final shouldShowDefaultContinue =
        !hasStepButtons && !hasGlobalButtons && !isQuestion;
    final showBack = currentIndex > 0;
    final canAdvance = controller.canAdvanceStreamValue.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasStepButtons)
          PushActionButtonsArea(
            controller: controller,
            buttonDataList: stepButtons,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            closeOnTap: isLastStep &&
                controller.messageData.closeOnLastStepAction.value,
          )
        else if (hasGlobalButtons)
          PushActionButtonsArea(
            controller: controller,
            buttonDataList: controller.messageData.buttons,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            closeOnTap: controller.messageData.closeOnLastStepAction.value,
          )
        else if (shouldShowDefaultContinue)
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: canAdvance
                  ? () async {
                      if (isLastStep) {
                        if (controller.messageData.closeOnLastStepAction.value) {
                          controller.requestClose();
                          Navigator.of(context).maybePop();
                        }
                        return;
                      }
                      await controller.toNext();
                    }
                  : null,
              child: const Text('Continuar'),
            ),
          ),
        if (showBack)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await controller.toPrevious();
                },
                icon: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.color,
                ),
                label: Text(
                  'voltar',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor:
                      Theme.of(context).textTheme.labelMedium?.color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
