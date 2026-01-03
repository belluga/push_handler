import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/dto/chat_data_dto.dart';
import 'package:push_handler/src/domain/dto/image_data_dto.dart';
import 'package:push_handler/src/domain/dto/step_data_dto.dart';

class MessageDataDTO {
  final String title;
  final String body;
  final ImageDataDTO? image;
  final String allowDismiss;
  final String layoutType;
  final String? backgroundColor;
  final String? onClickLayoutType;
  final ChatDataDTO? chat;
  final List<StepDataDTO> steps;
  final List<ButtonDataDTO> buttons;

  MessageDataDTO({
    required this.title,
    required this.body,
    required this.image,
    required this.allowDismiss,
    required this.layoutType,
    required this.backgroundColor,
    required this.steps,
    required this.buttons,
    this.onClickLayoutType,
    this.chat,
  });

  factory MessageDataDTO.fromMap(Map<String, dynamic> map) {
    final imageMap = map["image"];
    final Map<String, dynamic> resolvedImageMap =
        imageMap is Map<String, dynamic> ? imageMap : {};
    final stepsRaw = map['steps'];
    final buttonsRaw = map['buttons'];
    final stepsList = stepsRaw is List ? stepsRaw : const [];
    final buttonsList = buttonsRaw is List ? buttonsRaw : const [];

    return MessageDataDTO(
      title: map["title"]?.toString() ?? '',
      body: map["body"]?.toString() ?? '',
      image: ImageDataDTO.tryFromMap(resolvedImageMap),
      allowDismiss: map["allowDismiss"]?.toString() ?? 'false',
      layoutType: map['layoutType']?.toString() ?? '',
      backgroundColor: map['backgroundColor']?.toString(),
      onClickLayoutType: map['onClickLayoutType']?.toString(),
      steps: stepsList
          .whereType<Map<String, dynamic>>()
          .map((e) => StepDataDTO.fromMap(e))
          .toList(),
      buttons: buttonsList
          .whereType<Map<String, dynamic>>()
          .map((e) => ButtonDataDTO.fromMap(e))
          .toList(),
      chat: ChatDataDTO.tryFromMap(map["chat"] is Map<String, dynamic>
          ? map["chat"] as Map<String, dynamic>
          : null),
    );
  }
}
