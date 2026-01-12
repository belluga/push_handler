import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ButtonRouteNavigation {
  final PushWidgetController controller;
  final ButtonData buttonData;
  final BuildContext context;
  final bool closeOnTap;

  ButtonRouteNavigation({
    required this.buttonData,
    required this.controller,
    required this.context,
    required this.closeOnTap,
  });

  void navigate() {
    final ButtonRouteType? _routeType = buttonData.routeType.value;

    if (_routeType == null) {
      return;
    }

    switch (_routeType) {
      case ButtonRouteType.internalRoute:
        navigateToInternalWithItem();
        break;

      case ButtonRouteType.internalRouteWithItem:
        navigateToInternal();
        break;

      case ButtonRouteType.externalURL:
        navigateToExternal();
        break;
      case ButtonRouteType.customAction:
        if (closeOnTap) {
          controller.requestClose();
          Navigator.of(context, rootNavigator: true).pop();
        }
        break;
    }
  }

  Future<void> navigateToExternal() async {
    final rawUrl = buttonData.routeExternal.value?.toString() ?? '';
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return;
    }

    if (closeOnTap) {
      controller.requestClose();
      Navigator.of(context, rootNavigator: true).pop();
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  void navigateToInternal() {
    _navigateWithResolver(
      ButtonRouteType.internalRoute,
      route: buttonData.routeInternal.value,
      itemKey: null,
    );
  }

  void navigateToInternalWithItem() {
    _navigateWithResolver(
      ButtonRouteType.internalRouteWithItem,
      route: buttonData.routeInternal.value,
      itemKey: buttonData.itemKey.value.isEmpty
          ? null
          : buttonData.itemKey.value,
    );
  }

  void _navigateWithResolver(
    ButtonRouteType type, {
    required String route,
    String? itemKey,
  }) {
    final resolver = controller.navigationResolver;
    if (resolver == null) {
      return;
    }

    if (closeOnTap) {
      controller.requestClose();
      Navigator.of(context, rootNavigator: true).pop();
    }

    resolver(
      PushRouteRequest(
        type: type,
        route: route,
        routeKey: buttonData.routeKey.value.isEmpty
            ? null
            : buttonData.routeKey.value,
        pathParameters: buttonData.pathParameters,
        itemKey: itemKey,
      ),
    );
  }
}
