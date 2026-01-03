import 'package:flutter/material.dart';

class PushDismissButton extends StatelessWidget {
  final bool useCloseIcon;

  const PushDismissButton({
    super.key,
    this.useCloseIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useCloseIcon) {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.close,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

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
