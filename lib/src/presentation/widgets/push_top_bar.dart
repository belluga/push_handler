import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
class PushTopBar extends StatelessWidget {
  final PushWidgetController controller;

  const PushTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = controller.isLastStep;
    final step = controller.currentStep;
    final canSkip = !isLastStep && (step?.dismissible ?? false);

    if (!canSkip) {
      return const SizedBox(height: 32);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () async {
            await controller.skipCurrentStep();
          },
          child: Text(
            'Pular',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
