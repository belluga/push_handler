import 'package:enum_handler/enum_handler.dart';
import 'package:push_handler/src/domain/enums/button_action_type.dart';
import 'package:value_objects/value_object.dart';

class ButtonDataRouteTypeValue extends ValueObject<ButtonActionType?> {
  ButtonDataRouteTypeValue({
    super.isRequired = true,
    super.defaultValue,
  });

  @override
  ButtonActionType? doParse(String? parseValue) {
    return EnumHandler.enumOrNullFromString(
      values: ButtonActionType.values,
      value: parseValue ?? "",
    );
  }
}
