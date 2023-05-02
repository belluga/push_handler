import 'package:flutter/material.dart';

class PushDismissButton extends StatelessWidget {
  const PushDismissButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          "Pular",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
