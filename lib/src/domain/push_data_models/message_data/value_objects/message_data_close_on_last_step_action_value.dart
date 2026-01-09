import 'package:value_object_pattern/value_object.dart';

class MessageDataCloseOnLastStepActionValue extends ValueObject<bool> {
  MessageDataCloseOnLastStepActionValue({
    super.defaultValue = true,
    super.isRequired = true,
  });

  @override
  bool doParse(String? parseValue) {
    switch (parseValue) {
      case "1":
      case "true":
      case "True":
      case "TRUE":
        return true;

      default:
        return false;
    }
  }
}
