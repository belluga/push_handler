import 'package:value_object_pattern/value_object.dart';

class ButtonDataContinueAfterActionValue extends ValueObject<bool> {
  ButtonDataContinueAfterActionValue({
    super.defaultValue = false,
    super.isRequired = false,
  });

  @override
  bool doParse(String? parseValue) {
    switch (parseValue) {
      case '1':
      case 'true':
      case 'True':
      case 'TRUE':
        return true;
      default:
        return false;
    }
  }
}
