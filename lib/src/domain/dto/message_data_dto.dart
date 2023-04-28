import 'dart:convert';

import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/dto/step_data_dto.dart';

class MessageDataDTO {
  final String title;
  final String body;
  final String? imageURL;
  final String allowDismiss;
  final String layoutType;
  final List<StepDataDTO> steps;
  final List<ButtonDataDTO> buttons;

  MessageDataDTO({
    required this.title,
    required this.body,
    required this.imageURL,
    required this.allowDismiss,
    required this.layoutType,
    required this.steps,
    required this.buttons,
  });

  factory MessageDataDTO.fromMap(Map<String, dynamic> map) {
    return MessageDataDTO(
      title: map["title"],
      body: map["body"],
      imageURL: map["imageURL"],
      allowDismiss: map["allowDismiss"],
      layoutType: map['layoutType'],
      steps: (jsonDecode(map['steps']) as List)
          .map((e) => StepDataDTO.fromMap(e as Map<String,dynamic>))
          .toList(),
      buttons: (jsonDecode(map['buttons']) as List)
          .map((e) => ButtonDataDTO.fromMap(e as Map<String,dynamic>))
          .toList(),
    );
  }
}
