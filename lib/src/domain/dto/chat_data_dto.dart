import 'package:flutter/material.dart';
import 'package:push_handler/src/domain/dto/image_data_dto.dart';

class ChatDataDTO {
  final String buttonLabel;
  final String body;
  final ImageDataDTO? image;

  ChatDataDTO({
    required this.buttonLabel,
    required this.body,
    this.image,
  });

  static ChatDataDTO? tryFromMap(Map<String, dynamic>? map) {
    try {
      return ChatDataDTO.fromMap(map!);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  factory ChatDataDTO.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? _imageMap;

    try {
      _imageMap = map["image"] as Map<String, dynamic>;
    } catch (e) {
      _imageMap = {};
    }

    return ChatDataDTO(
      buttonLabel: map["buttonLabel"],
      body: map["body"],
      image: ImageDataDTO.tryFromMap(_imageMap),
    );
  }
}
