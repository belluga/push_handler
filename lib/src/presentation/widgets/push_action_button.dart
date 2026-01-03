import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/infrastructure/services/route_navigation.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

class PushActionButton extends StatelessWidget {
  final ButtonData buttonData;
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;

  const PushActionButton({
    super.key,
    required this.buttonData,
    required this.controller,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      child: ElevatedButton(
        onPressed: () => _navigate(context),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          backgroundColor:
              buttonData.color.value ?? Theme.of(context).colorScheme.onPrimary,
        ),
        child: Text(
          buttonData.label.value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    onButtonPressed?.call(
      buttonData,
      controller.currentIndexStreamValue.value,
    );
    final _buttonNavigation = ButtonRouteNavigation(
      buttonData: buttonData,
      controller: controller,
      context: context,
    );
    _buttonNavigation.navigate();
  }
}
