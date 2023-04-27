import 'package:enum_handler/enum_handler.dart';
import 'package:push_handler/src/domain/enums/step_content_type.dart';
import 'package:value_objects/value_object.dart';

class StepDataContentTypeValue extends ValueObject<StepContentType> {
  StepDataContentTypeValue({
    super.isRequired = true,
    super.defaultValue = StepContentType.html,
  });

  @override
  StepContentType doParse(String? parseValue) {
    return EnumHandler.enumFromString(
      values: StepContentType.values,
      value: parseValue ?? "",
      defaultValue: StepContentType.html,
    );
  }
}
