import 'package:push_handler/src/domain/enums/button_route_type.dart';

class PushRouteRequest {
  final ButtonRouteType type;
  final String route;
  final String? routeKey;
  final Map<String, String> pathParameters;
  final String? itemKey;

  const PushRouteRequest({
    required this.type,
    required this.route,
    this.routeKey,
    this.pathParameters = const {},
    this.itemKey,
  });
}

typedef PushNavigationResolver = Future<void> Function(
  PushRouteRequest request,
);
