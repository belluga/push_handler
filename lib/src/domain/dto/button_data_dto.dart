class ButtonDataDTO {
  final String label;
  final String routeType;
  final String? routeInternal;
  final String? routeExternal;
  final String? routeKey;
  final Map<String, dynamic>? pathParameters;
  final String? color;
  final String? itemKey;
  final String? customAction;
  final String? showLoading;
  final String? continueAfterAction;

  ButtonDataDTO({
    required this.label,
    required this.routeInternal,
    required this.routeExternal,
    required this.routeType,
    this.routeKey,
    this.pathParameters,
    this.color,
    this.itemKey,
    this.customAction,
    this.showLoading,
    this.continueAfterAction,
  });

  factory ButtonDataDTO.fromMap(Map<String, dynamic> map) {
    final action = map['action'];
    final actionMap =
        action is Map<String, dynamic> ? action : <String, dynamic>{};
    final rawType = actionMap['type'] ?? map['routeType'];
    final normalizedType = _normalizeRouteType(rawType);
    final customAction = actionMap['custom_action']?.toString();
    final continueAfterAction = (actionMap['continue_after_action'] ??
            map['continue_after_action'])
        ?.toString();
    final resolvedType = normalizedType.isEmpty && customAction != null
        ? _normalizeRouteType('custom')
        : normalizedType;
    final rawPathParameters = actionMap['path_parameters'];
    return ButtonDataDTO(
      label: map["label"],
      routeInternal: map['routeInternal'],
      routeExternal: actionMap['url'] ?? map['routeExternal'],
      routeType: resolvedType,
      routeKey: actionMap['route_key'],
      pathParameters:
          rawPathParameters is Map<String, dynamic> ? rawPathParameters : null,
      color: map['color'],
      itemKey: map['itemKey'],
      customAction: customAction,
      showLoading: map['show_loading']?.toString(),
      continueAfterAction: continueAfterAction,
    );
  }

  static String _normalizeRouteType(dynamic rawType) {
    final normalized = rawType?.toString() ?? '';
    switch (normalized) {
      case 'route':
        return 'internalRoute';
      case 'external':
        return 'externalURL';
      case 'custom':
        return 'customAction';
      case 'custom_action':
        return 'customAction';
      default:
        return normalized;
    }
  }
}
