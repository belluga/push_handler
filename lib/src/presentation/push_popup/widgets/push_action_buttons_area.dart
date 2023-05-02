import 'package:flutter/widgets.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_action_button.dart';

class PushActionButtonsArea extends StatelessWidget {
  final List<ButtonData> buttonDataList;
  final PushWidgetController controller;

  const PushActionButtonsArea({super.key, required this.buttonDataList, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          buttonDataList.length,
          (index) => PushActionButton(
            controller: controller,
            buttonData: buttonDataList[index],
          ),
        ),
      ),
    );
  }
}
