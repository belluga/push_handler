import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

class PushActionButton extends StatelessWidget {
  final ButtonData buttonData;

  const PushActionButton({super.key, required this.buttonData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: (){},
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonData.color.value ?? Theme.of(context).colorScheme.secondary,
    
        ),
        child: Text(buttonData.label.value),
      ),
    );
  }
}
