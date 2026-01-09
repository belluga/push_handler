import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

typedef PushActionReporter = Future<void> Function({
  required String action,
  required int stepIndex,
  required StepData step,
  String? buttonKey,
  ButtonData? button,
  String? deviceId,
});

class PushMessagePresenter {
  PushMessagePresenter({
    BuildContext? Function()? contextProvider,
    PushNavigationResolver? navigationResolver,
    this.gatekeeper,
    this.optionsBuilder,
    this.onStepSubmit,
    this.onCustomAction,
  })  : _contextProvider = contextProvider,
        _navigationResolver = navigationResolver;

  final BuildContext? Function()? _contextProvider;
  final PushNavigationResolver? _navigationResolver;
  final Future<bool> Function(StepData step)? gatekeeper;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;
  final Future<void> Function(ButtonData button, StepData step)? onCustomAction;

  Future<void> present({
    required MessageData messageData,
    required PushActionReporter reportAction,
    String? deviceId,
  }) async {
    var currentStepIndex = 0;
    void handleStepChanged(int stepIndex) {
      if (stepIndex < 0 || stepIndex >= messageData.steps.length) {
        return;
      }
      currentStepIndex = stepIndex;
      final step = messageData.steps[stepIndex];
      reportAction(
        action: 'step_viewed',
        stepIndex: stepIndex,
        step: step,
        deviceId: deviceId,
      );
    }

    void handleButtonPressed(ButtonData button, int stepIndex) {
      final buttonKey = _resolveButtonKey(button);
      final step = messageData.steps[stepIndex];
      reportAction(
        action: 'clicked',
        stepIndex: stepIndex,
        step: step,
        buttonKey: buttonKey,
        button: button,
        deviceId: deviceId,
      );
    }

    void handleGateBlocked(StepData step) {
      reportAction(
        action: 'gate_blocked',
        stepIndex: currentStepIndex,
        step: step,
        deviceId: deviceId,
      );
    }

    Future<void> handleStepSubmit(AnswerPayload answer, StepData step) async {
      if (onStepSubmit != null) {
        await onStepSubmit!(answer, step);
      }
      final stepIndex = messageData.steps.indexOf(step);
      await reportAction(
        action: 'submit',
        stepIndex: stepIndex == -1 ? currentStepIndex : stepIndex,
        step: step,
        deviceId: deviceId,
      );
    }

    if (messageData.steps.isNotEmpty) {
      await reportAction(
        action: 'opened',
        stepIndex: 0,
        step: messageData.steps.first,
        deviceId: deviceId,
      );
    }

    switch (messageData.layoutType.value) {
      case MessageLayoutType.popup:
        await _showDialog(
          builder: (context) => PushPopup(
            messageData: messageData,
            navigationResolver: _navigationResolver,
            onStepChanged: handleStepChanged,
            onButtonPressed: handleButtonPressed,
            onCustomAction: onCustomAction,
            gatekeeper: gatekeeper,
            optionsBuilder: optionsBuilder,
            onStepSubmit: onStepSubmit == null ? null : handleStepSubmit,
            onGateBlocked: handleGateBlocked,
          ),
          messageData: messageData,
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: () => currentStepIndex,
        );
        return;
      case MessageLayoutType.fullScreen:
        await _showGeneralDialog(
          builder: (context) => PushScreenFull(
            messageData: messageData,
            navigationResolver: _navigationResolver,
            onStepChanged: handleStepChanged,
            onButtonPressed: handleButtonPressed,
            onCustomAction: onCustomAction,
            gatekeeper: gatekeeper,
            optionsBuilder: optionsBuilder,
            onStepSubmit: onStepSubmit == null ? null : handleStepSubmit,
            onGateBlocked: handleGateBlocked,
          ),
          messageData: messageData,
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: () => currentStepIndex,
        );
        return;
      case MessageLayoutType.bottomModal:
        await _showBottomModal(
          messageData: messageData,
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: () => currentStepIndex,
          onStepChanged: handleStepChanged,
          onButtonPressed: handleButtonPressed,
          onCustomAction: onCustomAction,
          navigationResolver: _navigationResolver,
          gatekeeper: gatekeeper,
          optionsBuilder: optionsBuilder,
          onStepSubmit: onStepSubmit == null ? null : handleStepSubmit,
          onGateBlocked: handleGateBlocked,
        );
        return;
      case MessageLayoutType.actionButton:
      case MessageLayoutType.snackBar:
        await _showSnackBar(
          messageData: messageData,
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: () => currentStepIndex,
          onStepChanged: handleStepChanged,
          onButtonPressed: handleButtonPressed,
          onCustomAction: onCustomAction,
          navigationResolver: _navigationResolver,
          gatekeeper: gatekeeper,
          optionsBuilder: optionsBuilder,
          onStepSubmit: onStepSubmit == null ? null : handleStepSubmit,
          onGateBlocked: handleGateBlocked,
        );
        return;
    }
  }

    Future<void> _showDialog({
      required WidgetBuilder builder,
      required MessageData messageData,
      required PushActionReporter reportAction,
      String? deviceId,
      int Function()? stepIndexProvider,
    }) async {
    final context = _contextProvider?.call();
    if (context == null) return;
    await showDialog(
      context: context,
      builder: builder,
    );
    final stepIndex = stepIndexProvider?.call() ?? 0;
    final step = _resolveStep(messageData: messageData, stepIndex: stepIndex);
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      step: step,
      deviceId: deviceId,
    );
  }

  Future<void> _showGeneralDialog({
    required WidgetBuilder builder,
    required MessageData messageData,
    required PushActionReporter reportAction,
    String? deviceId,
    int Function()? stepIndexProvider,
  }) async {
    final context = _contextProvider?.call();
    if (context == null) return;
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    );
    final stepIndex = stepIndexProvider?.call() ?? 0;
    final step = _resolveStep(messageData: messageData, stepIndex: stepIndex);
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      step: step,
      deviceId: deviceId,
    );
  }

  Future<void> _showBottomModal({
    required MessageData messageData,
    required PushActionReporter reportAction,
    String? deviceId,
    int Function()? stepIndexProvider,
    ValueChanged<int>? onStepChanged,
    void Function(ButtonData button, int stepIndex)? onButtonPressed,
    Future<void> Function(ButtonData button, StepData step)? onCustomAction,
    PushNavigationResolver? navigationResolver,
    Future<bool> Function(StepData step)? gatekeeper,
    Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder,
    Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit,
    void Function(StepData step)? onGateBlocked,
  }) async {
    final context = _contextProvider?.call();
    if (context == null) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0),
      builder: (context) => InkWell(
        onTap: () => _showGeneralDialog(
          builder: (context) => PushScreenFull(
            messageData: messageData,
            navigationResolver: navigationResolver,
            onStepChanged: onStepChanged,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            gatekeeper: gatekeeper,
            optionsBuilder: optionsBuilder,
            onStepSubmit: onStepSubmit,
            onGateBlocked: onGateBlocked,
          ),
          messageData: messageData,
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: stepIndexProvider,
        ),
        child: PushModalBottomSheetContent(
          messageData: messageData,
          navigationResolver: navigationResolver,
          onStepChanged: onStepChanged,
          onButtonPressed: onButtonPressed,
          onCustomAction: onCustomAction,
          gatekeeper: gatekeeper,
          optionsBuilder: optionsBuilder,
          onStepSubmit: onStepSubmit,
          onGateBlocked: onGateBlocked,
          onTapExpand: () => _showGeneralDialog(
            builder: (context) => PushScreenFull(
            messageData: messageData,
            navigationResolver: navigationResolver,
            onStepChanged: onStepChanged,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            gatekeeper: gatekeeper,
            optionsBuilder: optionsBuilder,
            onStepSubmit: onStepSubmit,
            onGateBlocked: onGateBlocked,
          ),
            messageData: messageData,
            reportAction: reportAction,
            deviceId: deviceId,
            stepIndexProvider: stepIndexProvider,
          ),
        ),
      ),
    );
    final stepIndex = stepIndexProvider?.call() ?? 0;
    final step = _resolveStep(messageData: messageData, stepIndex: stepIndex);
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      step: step,
      deviceId: deviceId,
    );
  }

  Future<void> _showSnackBar({
    required MessageData messageData,
    required PushActionReporter reportAction,
    String? deviceId,
    int Function()? stepIndexProvider,
    ValueChanged<int>? onStepChanged,
    void Function(ButtonData button, int stepIndex)? onButtonPressed,
    Future<void> Function(ButtonData button, StepData step)? onCustomAction,
    PushNavigationResolver? navigationResolver,
    Future<bool> Function(StepData step)? gatekeeper,
    Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder,
    Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit,
    void Function(StepData step)? onGateBlocked,
  }) async {
    final context = _contextProvider?.call();
    if (context == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: InkWell(
          onTap: () => _showGeneralDialog(
            builder: (context) => PushScreenFull(
              messageData: messageData,
              navigationResolver: navigationResolver,
              onStepChanged: onStepChanged,
              onButtonPressed: onButtonPressed,
              onCustomAction: onCustomAction,
              gatekeeper: gatekeeper,
              optionsBuilder: optionsBuilder,
              onStepSubmit: onStepSubmit,
              onGateBlocked: onGateBlocked,
            ),
            messageData: messageData,
            reportAction: reportAction,
            deviceId: deviceId,
            stepIndexProvider: stepIndexProvider,
          ),
          child: PushSnackBarContent(
          messageData: messageData,
          navigationResolver: navigationResolver,
          onStepChanged: onStepChanged,
          onButtonPressed: onButtonPressed,
          onCustomAction: onCustomAction,
          gatekeeper: gatekeeper,
          optionsBuilder: optionsBuilder,
          onStepSubmit: onStepSubmit,
          onGateBlocked: onGateBlocked,
          onTapExpand: () => _showGeneralDialog(
            builder: (context) => PushScreenFull(
            messageData: messageData,
            navigationResolver: navigationResolver,
            onStepChanged: onStepChanged,
            onButtonPressed: onButtonPressed,
            onCustomAction: onCustomAction,
            gatekeeper: gatekeeper,
            optionsBuilder: optionsBuilder,
            onStepSubmit: onStepSubmit,
            onGateBlocked: onGateBlocked,
            ),
              messageData: messageData,
              reportAction: reportAction,
              deviceId: deviceId,
              stepIndexProvider: stepIndexProvider,
            ),
          ),
        ),
      ),
    );
    await controller.closed;
    final stepIndex = stepIndexProvider?.call() ?? 0;
    final step = _resolveStep(messageData: messageData, stepIndex: stepIndex);
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      step: step,
      deviceId: deviceId,
    );
  }

  StepData _resolveStep({required MessageData messageData, required int stepIndex}) {
    if (stepIndex >= 0 && stepIndex < messageData.steps.length) {
      return messageData.steps[stepIndex];
    }
    if (messageData.steps.isNotEmpty) {
      return messageData.steps.first;
    }
    return StepData.fromMap({
      'slug': '',
      'type': 'copy',
      'title': '',
      'body': '',
      'buttons': [],
    });
  }

  String _resolveButtonKey(ButtonData button) {
    final routeKey = button.routeKey.value;
    if (routeKey.isNotEmpty) {
      return routeKey;
    }
    final label = button.label.value;
    if (label.isNotEmpty) {
      return label;
    }
    return 'button';
  }
}
