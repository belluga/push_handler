import 'package:push_handler/main.dart';
import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_color_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_itemkey_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_label_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_external_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_type_value.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/value_objects/button_data_route_value.dart';

class ButtonData {
  final ButtonDataLabelValue label;
  final ButtonDataRouteValue routeInternal;
  final ButtonDataRouteExternal routeExternal;
  final ButtonDataRouteTypeValue routeType;
  final ButtonDataColorValue color;
  final ButtonDataItemKeyValue itemKey;

  ButtonData({
    required this.label,
    required this.routeInternal,
    required this.routeExternal,
    required this.routeType,
    required this.color,
    required this.itemKey,
  });

  factory ButtonData.fromMap(Map<String, dynamic> map) =>
      ButtonData.fromDTO(ButtonDataDTO.fromMap(map));

  factory ButtonData.fromDTO(ButtonDataDTO dto) {
    final _type = ButtonDataRouteTypeValue()..parse(dto.routeType);
    final _routeExternal = ButtonDataRouteExternal()..tryParse(dto.routeExternal);
    final _routeInternal = ButtonDataRouteValue()..tryParse(dto.routeInternal);

    if ([
          ButtonRouteType.internalRoute,
          ButtonRouteType.internalRouteWithItem,
        ].contains(_type.value) &&
        _routeInternal.value.isEmpty) {
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
      color: ButtonDataColorValue()..tryParse(dto.color),
      itemKey: ButtonDataItemKeyValue()..tryParse(dto.itemKey),
    );
  }
}
