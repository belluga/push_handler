import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_step_content.dart';

class PushStepsTab extends StatelessWidget {
  final PushWidgetController controller;

  const PushStepsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        controller.messageData.steps.length,
        (index) => PushStepContent(
          controller: controller,
        ),
      ),
    );
  }
}
