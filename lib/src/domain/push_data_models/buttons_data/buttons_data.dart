import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_color_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_custom_action_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_itemkey_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_label_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_key_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_external_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_type_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_show_loading_value.dart';

class ButtonData {
  final ButtonDataLabelValue label;
  final ButtonDataRouteValue routeInternal;
  final ButtonDataRouteExternal routeExternal;
  final ButtonDataRouteTypeValue routeType;
  final ButtonDataRouteKeyValue routeKey;
  final Map<String, String> pathParameters;
  final ButtonDataColorValue color;
  final ButtonDataItemKeyValue itemKey;
  final ButtonDataCustomActionValue customAction;
  final ButtonDataShowLoadingValue showLoading;

  ButtonData({
    required this.label,
    required this.routeInternal,
    required this.routeExternal,
    required this.routeType,
    required this.routeKey,
    required this.pathParameters,
    required this.color,
    required this.itemKey,
    required this.customAction,
    required this.showLoading,
  });

  factory ButtonData.fromMap(Map<String, dynamic> map) =>
      ButtonData.fromDTO(ButtonDataDTO.fromMap(map));

  factory ButtonData.fromDTO(ButtonDataDTO dto) {
    final _type = ButtonDataRouteTypeValue()..parse(dto.routeType);
    final _routeExternal = ButtonDataRouteExternal()..tryParse(dto.routeExternal);
    final _routeInternal = ButtonDataRouteValue()..tryParse(dto.routeInternal);
    final _routeKey = ButtonDataRouteKeyValue()..tryParse(dto.routeKey);
    final _pathParameters = _normalizePathParameters(dto.pathParameters);
    final _customAction =
        ButtonDataCustomActionValue()..tryParse(dto.customAction);
    final _showLoading =
        ButtonDataShowLoadingValue()..parse(dto.showLoading);

    if ([
          ButtonRouteType.internalRoute,
          ButtonRouteType.internalRouteWithItem,
        ].contains(_type.value) &&
        _routeInternal.value.isEmpty &&
        _routeKey.value.isEmpty) {
      throw Exception(
          "If the type is 'internalRoute' or 'internalRouteWithItem' then '_routeInternal' should not be empty");
    }

    if (_type.value == ButtonRouteType.externalURL &&
        _routeExternal.value == null) {
      throw Exception(
          "If the type is 'externalURL' then '_routeExternal' should not be empty");
    }

    return ButtonData(
      label: ButtonDataLabelValue()..parse(dto.label),
      routeInternal: ButtonDataRouteValue()..tryParse(dto.routeInternal),
      routeExternal: ButtonDataRouteExternal()..tryParse(dto.routeExternal),
      routeType: ButtonDataRouteTypeValue()..parse(dto.routeType),
      routeKey: ButtonDataRouteKeyValue()..tryParse(dto.routeKey),
      pathParameters: _pathParameters,
      color: ButtonDataColorValue()..tryParse(dto.color),
      itemKey: ButtonDataItemKeyValue()..tryParse(dto.itemKey),
      customAction: _customAction,
      showLoading: _showLoading,
    );
  }

  static Map<String, String> _normalizePathParameters(
    Map<String, dynamic>? rawParameters,
  ) {
    if (rawParameters == null || rawParameters.isEmpty) {
      return const {};
    }
    final normalized = <String, String>{};
    rawParameters.forEach((key, value) {
      if (value == null) return;
      normalized[key] = value.toString();
    });
    return normalized;
  }
}
