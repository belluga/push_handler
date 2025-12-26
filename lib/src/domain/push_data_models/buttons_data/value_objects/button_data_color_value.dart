import 'package:value_object_pattern/value_object.dart';

import 'package:flutter/material.dart';

class ButtonDataColorValue extends ValueObject<Color?> {
  ButtonDataColorValue({
    super.isRequired = false,
    super.defaultValue,
  });

  @override
  Color? doParse(String? parseValue) {
    if (parseValue == null || parseValue.isEmpty) {
      return null;
    }
    final String _cleanedValue = parseValue.replaceAll("#", "");
    return Color(
        int.parse(_cleanedValue.substring(0, 6), radix: 16) + 0xFF000000);
  }
}
