import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:push_handler/push_handler.dart';

class PushStepContent extends StatelessWidget {

  final StepData stepData;

  const PushStepContent({super.key, required this.stepData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
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
      ),
    );
  }
}
