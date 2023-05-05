import 'package:value_objects/value_object.dart';

class MessageDataDimensionDataValue extends ValueObject<double> {
  MessageDataDimensionDataValue({
    super.defaultValue = 150.0,
    super.isRequired = true,
  });

  @override
  double doParse(String? parseValue) {
    return double.tryParse(parseValue ?? "") ?? defaultValue;
  }
}
