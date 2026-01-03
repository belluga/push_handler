import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

typedef PushActionReporter = Future<void> Function({
  required String action,
  required int stepIndex,
  String? buttonKey,
  String? deviceId,
});

class PushMessagePresenter {
  PushMessagePresenter({
    BuildContext? Function()? contextProvider,
    PushNavigationResolver? navigationResolver,
  })  : _contextProvider = contextProvider,
        _navigationResolver = navigationResolver;

  final BuildContext? Function()? _contextProvider;
  final PushNavigationResolver? _navigationResolver;

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
      reportAction(
        action: 'step_viewed',
        stepIndex: stepIndex,
        deviceId: deviceId,
      );
    }

    void handleButtonPressed(ButtonData button, int stepIndex) {
      final buttonKey = _resolveButtonKey(button);
      reportAction(
        action: 'clicked',
        stepIndex: stepIndex,
        buttonKey: buttonKey,
        deviceId: deviceId,
      );
    }

    await reportAction(
      action: 'opened',
      stepIndex: 0,
      deviceId: deviceId,
    );

    switch (messageData.layoutType.value) {
      case MessageLayoutType.popup:
        await _showDialog(
          builder: (context) => PushPopup(
            messageData: messageData,
            navigationResolver: _navigationResolver,
            onStepChanged: handleStepChanged,
            onButtonPressed: handleButtonPressed,
          ),
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
          ),
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
          navigationResolver: _navigationResolver,
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
          navigationResolver: _navigationResolver,
        );
        return;
    }
  }

  Future<void> _showDialog({
    required WidgetBuilder builder,
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
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      deviceId: deviceId,
    );
  }

  Future<void> _showGeneralDialog({
    required WidgetBuilder builder,
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
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
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
    PushNavigationResolver? navigationResolver,
  }) async {
    final context = _contextProvider?.call();
    if (context == null) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: messageData.allowDismiss.value,
      backgroundColor: Colors.transparent,
      builder: (context) => InkWell(
        onTap: () => _showGeneralDialog(
          builder: (context) => PushScreenFull(
            messageData: messageData,
            navigationResolver: navigationResolver,
            onStepChanged: onStepChanged,
            onButtonPressed: onButtonPressed,
          ),
          reportAction: reportAction,
          deviceId: deviceId,
          stepIndexProvider: stepIndexProvider,
        ),
        child: PushModalBottomSheetContent(
          messageData: messageData,
          navigationResolver: navigationResolver,
          onStepChanged: onStepChanged,
          onButtonPressed: onButtonPressed,
          onTapExpand: () => _showGeneralDialog(
            builder: (context) => PushScreenFull(
              messageData: messageData,
              navigationResolver: navigationResolver,
              onStepChanged: onStepChanged,
              onButtonPressed: onButtonPressed,
            ),
            reportAction: reportAction,
            deviceId: deviceId,
            stepIndexProvider: stepIndexProvider,
          ),
        ),
      ),
    );
    final stepIndex = stepIndexProvider?.call() ?? 0;
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
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
    PushNavigationResolver? navigationResolver,
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
        backgroundColor: messageData.backgroundColor.value,
        content: InkWell(
          onTap: () => _showGeneralDialog(
            builder: (context) => PushScreenFull(
              messageData: messageData,
              navigationResolver: navigationResolver,
              onStepChanged: onStepChanged,
              onButtonPressed: onButtonPressed,
            ),
            reportAction: reportAction,
            deviceId: deviceId,
            stepIndexProvider: stepIndexProvider,
          ),
          child: PushSnackBarContent(
            messageData: messageData,
            navigationResolver: navigationResolver,
            onStepChanged: onStepChanged,
            onButtonPressed: onButtonPressed,
            onTapExpand: () => _showGeneralDialog(
              builder: (context) => PushScreenFull(
                messageData: messageData,
                navigationResolver: navigationResolver,
                onStepChanged: onStepChanged,
                onButtonPressed: onButtonPressed,
              ),
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
    await reportAction(
      action: 'dismissed',
      stepIndex: stepIndex,
      deviceId: deviceId,
    );
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
