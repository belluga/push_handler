import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/domain/dto/message_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/value_objects/message_data_allow_dismiss_value.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/value_objects/message_data_body_value.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/value_objects/message_data_image_url_value.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/value_objects/message_data_layout_type_value.dart';
import 'package:push_handler/src/domain/push_data_models/message_data/value_objects/message_data_title_value.dart';

class MessageData {
  final MessageDataTitleValue title;
  final MessageDataBodyValue body;
  final MessageDataImageURLValue imageURL;
  final MessageDataAllowDismissValue allowDismiss;
  final MessageDataLayoutTypeValue layoutType;
  final List<StepData> steps;
  final List<ButtonData> buttons;

  MessageData({
    required this.title,
    required this.body,
    required this.imageURL,
    required this.allowDismiss,
    required this.layoutType,
    required this.steps,
    required this.buttons,
  });

  factory MessageData.fromMap(Map<String, dynamic> map) =>
      MessageData.fromDTO(MessageDataDTO.fromMap(map));

  factory MessageData.fromDTO(MessageDataDTO dto) {
    return MessageData(
      title: MessageDataTitleValue()..parse(dto.title),
      body: MessageDataBodyValue()..parse(dto.body),
      imageURL: MessageDataImageURLValue()..tryParse(dto.imageURL),
      allowDismiss: MessageDataAllowDismissValue()
        ..parse(dto.allowDismiss),
      layoutType: MessageDataLayoutTypeValue()..parse(dto.layoutType),
      steps: dto.steps.map((e) => StepData.fromDTO(e)).toList(),
      buttons: dto.buttons.map((e) => ButtonData.fromDTO(e)).toList(),
    );
  }
}
