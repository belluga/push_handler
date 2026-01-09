import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/infrastructure/services/route_navigation.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

class PushActionButton extends StatefulWidget {
  final ButtonData buttonData;
  final PushWidgetController controller;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;
  final Future<void> Function(ButtonData button, StepData step)? onCustomAction;
  final bool closeOnTap;

  const PushActionButton({
    super.key,
    required this.buttonData,
    required this.controller,
    this.onButtonPressed,
    this.onCustomAction,
    required this.closeOnTap,
  });

  static ButtonStyle primaryStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    );
  }

  @override
  State<PushActionButton> createState() => _PushActionButtonState();
}

class _PushActionButtonState extends State<PushActionButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final shouldShowLoading = widget.buttonData.showLoading.value;
    final isDisabled = shouldShowLoading && _isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
        );
    final buttonStyle = PushActionButton.primaryStyle(context);

    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _handlePress(context),
        style: buttonStyle,
        child: shouldShowLoading && _isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.buttonData.label.value, style: labelStyle),
                ],
              )
            : Text(widget.buttonData.label.value, style: labelStyle),
      ),
    );
  }


  Future<void> _handlePress(BuildContext context) async {
    final shouldShowLoading = widget.buttonData.showLoading.value;
    if (shouldShowLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _navigate(context);
    } finally {
      if (!mounted) return;
      if (shouldShowLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigate(BuildContext context) async {
    widget.onButtonPressed?.call(
      widget.buttonData,
      widget.controller.currentIndexStreamValue.value,
    );
    if (widget.buttonData.routeType.value == ButtonRouteType.customAction) {
      final customAction = widget.buttonData.customAction.value.trim();
      final step = widget.controller.currentStep;
      if (step == null) {
        return;
      }
      if (customAction.isEmpty || customAction == 'noop') {
        if (widget.closeOnTap) {
          widget.controller.requestClose();
          Navigator.of(context).maybePop();
        } else {
          await widget.controller.toNext();
        }
        return;
      }
      await widget.onCustomAction?.call(widget.buttonData, step);
      await widget.controller.advanceAfterGateAction();
      if (widget.closeOnTap) {
        widget.controller.requestClose();
        Navigator.of(context).maybePop();
      }
      return;
    }
    final buttonNavigation = ButtonRouteNavigation(
      buttonData: widget.buttonData,
      controller: widget.controller,
      context: context,
      closeOnTap: widget.closeOnTap,
    );
    buttonNavigation.navigate();
  }
}
