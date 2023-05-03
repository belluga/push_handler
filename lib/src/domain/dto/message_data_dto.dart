import 'dart:convert';

import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/dto/image_data_dto.dart';
import 'package:push_handler/src/domain/dto/step_data_dto.dart';

class MessageDataDTO {
  final String title;
  final String body;
  final ImageDataDTO? image;
  final String allowDismiss;
  final String layoutType;
  final String? onClickLayoutType;
  final List<StepDataDTO> steps;
  final List<ButtonDataDTO> buttons;

  MessageDataDTO({
    required this.title,
    required this.body,
    required this.image,
    required this.allowDismiss,
    required this.layoutType,
    required this.steps,
    required this.buttons,
    this.onClickLayoutType,
  });

  factory MessageDataDTO.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? _imageMap;

    try {
      _imageMap = jsonDecode(map["image"]);
    } catch (e) {
      _imageMap = {};
    }

    return MessageDataDTO(
      title: map["title"],
      body: map["body"],
      image: ImageDataDTO.tryFromMap(_imageMap),
      allowDismiss: map["allowDismiss"],
      layoutType: map['layoutType'],
      onClickLayoutType: map['onClickLayoutType'],
      steps: (jsonDecode(map['steps']) as List)
          .map((e) => StepDataDTO.fromMap(e as Map<String, dynamic>))
          .toList(),
      buttons: (jsonDecode(map['buttons']) as List)
          .map((e) => ButtonDataDTO.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
