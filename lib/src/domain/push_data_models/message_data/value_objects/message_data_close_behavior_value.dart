import 'package:push_handler/src/domain/enums/message_close_behavior.dart';
import 'package:push_handler/src/domain/utils/enum_handler.dart';
import 'package:value_object_pattern/value_object.dart';

class MessageDataCloseBehaviorValue extends ValueObject<MessageCloseBehavior> {
  MessageDataCloseBehaviorValue({
    super.isRequired = true,
    super.defaultValue = MessageCloseBehavior.after_action,
  });

  @override
  MessageCloseBehavior doParse(String? parseValue) {
    return EnumHandler.enumFromString(
      values: MessageCloseBehavior.values,
      value: parseValue ?? '',
      defaultValue: MessageCloseBehavior.after_action,
    );
  }
}
