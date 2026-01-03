import 'package:flutter/material.dart';
import 'package:value_object_pattern/value_object.dart';

class MessageDataBackgroundColorValue extends ValueObject<Color?> {
  MessageDataBackgroundColorValue({
    super.isRequired = false,
    super.defaultValue,
  });

  @override
  Color? doParse(String? parseValue) {
    if (parseValue == null || parseValue.isEmpty) {
      return null;
    }
    final cleanedValue = parseValue.replaceAll("#", "");
    return Color(int.parse(cleanedValue.substring(0, 6), radix: 16) + 0xFF000000);
  }
}
