import 'package:flutter/material.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_dismiss_button.dart';
import 'package:stream_value/core/stream_value_builder.dart';

class PushTopBar extends StatelessWidget {
  final PushWidgetController controller;

  const PushTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool _allowDismiss = controller.messageData.allowDismiss.value;
    final bool _haveBackButton = controller.currentIndexStreamValue.value > 0;

    if (_allowDismiss == false && _haveBackButton == false) {
      return const SizedBox(height: 32);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_haveBackButton)
          IconButton(
            onPressed: controller.toPrevious,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        if (_allowDismiss) const PushDismissButton(),
      ],
    );
  }
}
