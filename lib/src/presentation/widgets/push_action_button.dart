import 'package:flutter/material.dart';
import 'package:push_handler/main.dart';
import 'package:push_handler/src/infrastructure/services/route_navigation.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

class PushActionButton extends StatelessWidget {
  final ButtonData buttonData;
  final PushWidgetController controller;

  const PushActionButton({super.key, required this.buttonData, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      child: ElevatedButton(
        onPressed: _navigate,
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

  _navigate() {
    final _buttonNavigation = ButtonRouteNavigation(buttonData: buttonData, controller: controller);
    _buttonNavigation.navigate();
  }
}
