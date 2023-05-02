import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/push_popup/widgets/push_step_content.dart';

class PushStepsTab extends StatelessWidget {
  final List<StepData> stepData;
  final TabController tabController;

  const PushStepsTab(
      {super.key, required this.stepData, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        stepData.length,
        (index) => PushStepContent(
          stepData: stepData[index],
        ),
      ),
    );
  }
}
