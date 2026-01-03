import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:flutter/material.dart';

class ButtonRouteNavigation {
  final PushWidgetController controller;
  final ButtonData buttonData;
  final BuildContext context;

  ButtonRouteNavigation({
    required this.buttonData,
    required this.controller,
    required this.context,
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
    }
  }

  void navigateToExternal() {
    _navigateWithResolver(
      ButtonRouteType.externalURL,
      route: buttonData.routeExternal.value?.toString() ?? '',
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

    Navigator.of(context).maybePop();

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
