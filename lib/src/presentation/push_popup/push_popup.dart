import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_action_buttons_area.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_dismiss_button.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_steps_tab.dart';
import 'package:push_handler/src/presentation/push_widget.dart';

class PushPopup extends PushWidget {
  const PushPopup({super.key, required super.messageData});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height/3,
                    maxHeight: MediaQuery.of(context).size.height/1.5,
                  ),
                  // height: MediaQuery.of(context).size.height/2,
                  child: PushStepsTab(
                    stepData: controller.messageData.steps,
                    tabController: controller.tabController,
                  ),
                ),
                if (isLastTab == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (currentIndex != 0)
                        ElevatedButton(
                            onPressed: toPrevious, child: Text("Voltar")),
                      ElevatedButton(onPressed: toNext, child: Text("Próximo")),
                    ],
                  ),
                if (isLastTab == true)
                  PushActionButtonsArea(
                      buttonDataList: controller.messageData.buttons),
              ],
            ),
          ),
          if (controller.messageData.allowDismiss.value)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                PushDismissButton(),
              ],
            ),
        ],
      ),
    );
  }
}
