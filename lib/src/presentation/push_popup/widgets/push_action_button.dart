import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

class PushActionButton extends StatelessWidget {
  final ButtonData buttonData;

  const PushActionButton({super.key, required this.buttonData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      child: ElevatedButton(
        onPressed: () {},
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
}
