import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

class PushStepContent extends StatelessWidget {
  final StepData stepData;

  const PushStepContent({super.key, required this.stepData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            stepData.content.value,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
