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
    if (map == null) return null;
    try {
      return ChatDataDTO.fromMap(map);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  factory ChatDataDTO.fromMap(Map<String, dynamic> map) {
    final imageMap = map["image"];
    final Map<String, dynamic> resolvedImageMap =
        imageMap is Map<String, dynamic> ? imageMap : {};

    return ChatDataDTO(
      buttonLabel: map["buttonLabel"]?.toString() ?? '',
      body: map["body"]?.toString() ?? '',
      image: ImageDataDTO.tryFromMap(resolvedImageMap),
    );
  }
}
