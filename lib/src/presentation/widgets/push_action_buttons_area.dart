import 'package:flutter/widgets.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_button.dart';

class PushActionButtonsArea extends StatelessWidget {
  final List<ButtonData> buttonDataList;
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;

  const PushActionButtonsArea({
    super.key,
    required this.buttonDataList,
    required this.controller,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          buttonDataList.length,
          (index) => PushActionButton(
            controller: controller,
            buttonData: buttonDataList[index],
            onButtonPressed: onButtonPressed,
          ),
        ),
      ),
    );
  }
}
