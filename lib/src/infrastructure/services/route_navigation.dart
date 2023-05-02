import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/domain/keys/push_handler_keys.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ButtonRouteNavigation {
  final PushWidgetController controller;
  final ButtonData buttonData;

  ButtonRouteNavigation({required this.buttonData, required this.controller});

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
    final Uri? _externalRoute = buttonData.routeExternal.value;
    final BuildContext? _currentContext =
        controller.navigatorKey.currentContext;

    if (_externalRoute != null &&
        _externalRoute.toString().isNotEmpty &&
        _currentContext != null) {
      Navigator.of(_currentContext).pop();
      launchUrl(_externalRoute);
    }
  }

  void navigateToInternal() {
    final String _internalRoute = buttonData.routeInternal.value;
    final BuildContext? _currentContext =
        controller.navigatorKey.currentContext;

    if (_internalRoute.isNotEmpty && _currentContext != null) {
      Navigator.of(_currentContext).pop();
      Navigator.of(_currentContext).pushNamed(_internalRoute);
    }
  }

  void navigateToInternalWithItem() {
    final String _internalRoute = buttonData.routeInternal.value;
    final String _itemIDString = buttonData.itemKey.value;
    Object? _argumentsObject;
    final BuildContext? _currentContext =
        controller.navigatorKey.currentContext;

    if (_internalRoute.isNotEmpty && _currentContext != null) {
      Navigator.of(_currentContext).pop();

      if (_itemIDString.isNotEmpty) {
        _argumentsObject = {
          PushHandlerKeys.itemArgumentKey: buttonData.itemKey
        };
      }

      Navigator.of(_currentContext)
          .pushNamed(_internalRoute, arguments: _argumentsObject);
    }
  }
}
