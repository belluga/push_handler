import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_steps_tab.dart';
import 'package:push_handler/src/presentation/push_widget.dart';

class PushPopup extends PushWidget {
  const PushPopup({
    super.key,
    required super.messageData,
    super.navigationResolver,
    super.onStepChanged,
    super.onButtonPressed,
    super.onCustomAction,
    super.gatekeeper,
    super.optionsBuilder,
    super.onStepSubmit,
    super.onGateBlocked,
  });

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
        if (controller.currentIndexStreamValue.value > 0) {
          await controller.toPrevious();
        }
        return false;
      },
      child: PushStepsTab(
        controller: controller,
        onButtonPressed: widget.onButtonPressed,
        onCustomAction: widget.onCustomAction,
        optionsBuilder: widget.optionsBuilder,
        onStepSubmit: widget.onStepSubmit,
      ),
    );
  }
}
