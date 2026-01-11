import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_step_question_content.dart';

class PushStepSelectorContent extends StatelessWidget {
  const PushStepSelectorContent({
    super.key,
    required this.stepData,
    required this.controller,
    this.optionsBuilder,
    this.onStepSubmit,
    this.stepValidator,
  });

  final StepData stepData;
  final PushWidgetController controller;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;
  final String? Function(StepData step, String? value)? stepValidator;

  @override
  Widget build(BuildContext context) {
    return PushStepQuestionContent(
      stepData: stepData,
      controller: controller,
      optionsBuilder: optionsBuilder,
      onStepSubmit: onStepSubmit,
      stepValidator: stepValidator,
    );
  }
}
