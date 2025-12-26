import 'package:push_handler/src/domain/utils/enum_handler.dart';
import 'package:push_handler/src/domain/enums/button_route_type.dart';
import 'package:value_object_pattern/value_object.dart';

class ButtonDataRouteTypeValue extends ValueObject<ButtonRouteType?> {
  ButtonDataRouteTypeValue({
    super.isRequired = true,
    super.defaultValue,
  });

  @override
  ButtonRouteType? doParse(String? parseValue) {
    return EnumHandler.enumOrNullFromString(
      values: ButtonRouteType.values,
      value: parseValue ?? "",
    );
  }
}
