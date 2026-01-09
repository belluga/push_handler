import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_step_body.dart';
import 'package:push_handler/src/presentation/widgets/push_step_question_content.dart';

class PushStepContent extends StatelessWidget {
  final EdgeInsets? padding;
  final StepData stepData;
  final PushWidgetController? controller;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;

  const PushStepContent({
    super.key,
    required this.stepData,
    this.padding,
    this.controller,
    this.optionsBuilder,
    this.onStepSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final ImageData? _imageData = stepData.image;
    final isQuestion = stepData.type == 'question' || stepData.type == 'selector';
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imageData != null)
            Container(
              width: _imageData.widthValue.value,
              height: _imageData.heightValue.value,
              margin: const EdgeInsets.all(8),
              child: Image.network(
                _imageData.pathValue.value.toString(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          if (_imageData != null) const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  stepData.title.value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(color: textColor),
                ),
              ),
            ],
          ),
          if (stepData.body.value.isNotEmpty) const SizedBox(height: 16),
          if (stepData.body.value.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: PushStepBody(
                    body: stepData.body.value,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
          if (isQuestion && controller != null) const SizedBox(height: 24),
          if (isQuestion && controller != null)
            PushStepQuestionContent(
              stepData: stepData,
              controller: controller!,
              optionsBuilder: optionsBuilder,
              onStepSubmit: onStepSubmit,
            ),
        ],
      ),
    );
  }
}
