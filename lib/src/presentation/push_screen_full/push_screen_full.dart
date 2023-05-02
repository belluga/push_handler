import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_widget.dart';
import 'package:push_handler/src/presentation/widgets/push_bottom_buttons.dart';
import 'package:push_handler/src/presentation/widgets/push_step_content.dart';
import 'package:push_handler/src/presentation/widgets/push_top_bar.dart';

class PushScreenFull extends PushWidget {
  const PushScreenFull(
      {super.key, required super.messageData, required super.navigatorKey});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              PushTopBar(controller: controller),
              Expanded(
                child: PushStepContent(
                  stepData: controller.messageData
                      .steps[controller.currentIndexStreamValue.value],
                ),
              ),
              PushBottomButtons(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
