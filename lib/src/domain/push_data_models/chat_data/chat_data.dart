import 'package:flutter/material.dart';
import 'package:push_handler/src/domain/dto/chat_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/chat_data/value_objects/chat_button_data_label_value.dart';
import 'package:push_handler/src/domain/push_data_models/chat_data/value_objects/chat_data_body_value.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';

class ChatData {
  final ChatButtonDataLabelValue label;
  final ChatDataBodyValue body;
  final ImageData? image;

  ChatData({
    required this.label,
    required this.body,
    this.image,
  });

  factory ChatData.fromMap(Map<String, dynamic> map) =>
      ChatData.fromDTO(ChatDataDTO.fromMap(map));

  factory ChatData.fromDTO(ChatDataDTO dto) {
    return ChatData(
      label: ChatButtonDataLabelValue()..parse(dto.buttonLabel),
      body: ChatDataBodyValue()..tryParse(dto.body),
      image: ImageData.tryFromDTO(dto.image),
    );
  }

  static ChatData? tryFromDTO(ChatDataDTO? dto) {
    if (dto == null) return null;
    try {
      return ChatData.fromDTO(dto);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}
