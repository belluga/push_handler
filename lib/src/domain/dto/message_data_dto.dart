import 'package:push_handler/src/domain/dto/button_data_dto.dart';
import 'package:push_handler/src/domain/dto/step_data_dto.dart';

class MessageDataDTO {
  final String title;
  final String body;
  final String imageURL;
  final bool allowDismiss;
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
    print("MessageDataDTO.fromMap");
    print("map");
    print(map);

    return MessageDataDTO(
      title:  map["title"],
      body: map["body"],
      imageURL: map["imageURL"],
      allowDismiss: map["allowDismiss"],
      layoutType: map['layoutType'],
      steps: (map['steps'] as List<Map<String, dynamic>>)
          .map((e) => StepDataDTO.fromMap(e))
          .toList(),
      buttons: (map['buttons'] as List<Map<String, dynamic>>)
          .map((e) => ButtonDataDTO.fromMap(e))
          .toList(),
    );
  }
}
