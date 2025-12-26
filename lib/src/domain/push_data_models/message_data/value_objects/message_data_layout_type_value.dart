import 'package:push_handler/src/domain/utils/enum_handler.dart';
import 'package:push_handler/src/domain/enums/message_layout_type.dart';
import 'package:value_object_pattern/value_object.dart';

class MessageDataLayoutTypeValue extends ValueObject<MessageLayoutType> {
  MessageDataLayoutTypeValue({
    super.isRequired = true,
    super.defaultValue = MessageLayoutType.bottomModal,
  });

  @override
  MessageLayoutType doParse(String? parseValue) {
    return EnumHandler.enumFromString(
        values: MessageLayoutType.values,
        value: parseValue ?? "",
        defaultValue: MessageLayoutType.bottomModal);
  }
}
