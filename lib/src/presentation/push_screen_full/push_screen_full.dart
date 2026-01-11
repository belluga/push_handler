import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_widget.dart';
import 'package:push_handler/src/presentation/widgets/push_bottom_buttons.dart';
import 'package:push_handler/src/presentation/widgets/push_step_content.dart';
import 'package:push_handler/src/presentation/widgets/push_top_bar.dart';

class PushScreenFull extends PushWidget {
  const PushScreenFull(
      {super.key,
      required super.messageData,
      super.navigationResolver,
      super.onStepChanged,
      super.onButtonPressed,
      super.onCustomAction,
      super.gatekeeper,
      super.optionsBuilder,
      super.onStepSubmit,
      super.stepValidator,
      super.onGateBlocked});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const SizedBox.shrink();
    }
    return WillPopScope(
      onWillPop: () async {
        if (controller.consumeCloseRequest()) {
          return true;
        }
        if (controller.currentIndexStreamValue.value > 0) {
          await controller.toPrevious();
        }
        return false;
      },
      child: Material(
        child: Container(
          color: controller.resolveBackgroundColor(context),
          child: SafeArea(
            child: Column(
              children: [
                PushTopBar(controller: controller),
                Expanded(
                  child: PushStepContent(
                    padding: const EdgeInsets.all(64),
                    stepData: controller.messageData
                        .steps[controller.currentIndexStreamValue.value],
                    controller: controller,
                    optionsBuilder: widget.optionsBuilder,
                    onStepSubmit: widget.onStepSubmit,
                    stepValidator: widget.stepValidator,
                  ),
                ),
                PushBottomButtons(
                  controller: controller,
                  onButtonPressed: widget.onButtonPressed,
                  onCustomAction: widget.onCustomAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
