import 'dart:async';

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
    super.stepValidator,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (controller.consumeCloseRequest()) {
          unawaited(Navigator.of(context).maybePop());
          return;
        }
        if (controller.consumeBackSuppression()) {
          return;
        }
        if (controller.currentIndexStreamValue.value > 0) {
          unawaited(controller.toPrevious());
        }
      },
      child: PushStepsTab(
        controller: controller,
        onButtonPressed: widget.onButtonPressed,
        onCustomAction: widget.onCustomAction,
        optionsBuilder: widget.optionsBuilder,
        onStepSubmit: widget.onStepSubmit,
        stepValidator: widget.stepValidator,
      ),
    );
  }
}
