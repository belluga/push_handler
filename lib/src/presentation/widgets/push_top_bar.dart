import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
class PushTopBar extends StatelessWidget {
  final PushWidgetController controller;

  const PushTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = controller.isLastStep;
    final step = controller.currentStep;
    final canSkip = !isLastStep && (step?.dismissible ?? false);
    final canGoBack = controller.currentIndexStreamValue.value > 0;
    final closeBehavior = controller.messageData.closeBehavior.value;
    final showClose =
        isLastStep && closeBehavior == MessageCloseBehavior.close_button;

    if (!canSkip && !showClose && !canGoBack) {
      return const SizedBox(height: 32);
    }

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Row(
        children: [
          if (canGoBack)
            TextButton.icon(
              onPressed: () async {
                await controller.toPrevious();
              },
              icon: Icon(
                Icons.chevron_left,
                size: 20,
                color: Theme.of(context).textTheme.labelLarge?.color,
              ),
              label: Text(
                'voltar',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    Theme.of(context).textTheme.labelLarge?.color,
              ),
            ),
          const Spacer(),
          if (showClose)
            IconButton(
              onPressed: () {
                controller.requestClose();
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: const Icon(Icons.close),
              tooltip: 'Fechar',
            ),
          if (canSkip)
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
      ),
    );
  }
}
