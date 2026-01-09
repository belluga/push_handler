import 'package:push_handler/src/domain/dto/image_data_dto.dart';
import 'package:push_handler/src/domain/dto/button_data_dto.dart';

class StepDataDTO {
  final String slug;
  final String type;
  final String title;
  final String? body;
  final ImageDataDTO? image;
  final bool? dismissible;
  final Map<String, dynamic>? gate;
  final Map<String, dynamic>? onSubmit;
  final Map<String, dynamic>? config;
  final List<ButtonDataDTO> buttons;

  StepDataDTO({
    required this.slug,
    required this.type,
    required this.title,
    this.body,
    this.image,
    this.dismissible,
    this.gate,
    this.onSubmit,
    this.config,
    required this.buttons,
  });

  factory StepDataDTO.fromMap(Map<String, dynamic> map) {
    final gateRaw = map['gate'];
    final onSubmitRaw = map['onSubmit'];
    final configRaw = map['config'];
    final buttonsRaw = map['buttons'];
    final buttonsList = buttonsRaw is List ? buttonsRaw : const [];

    return StepDataDTO(
      slug: map['slug']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString(),
      image: ImageDataDTO.tryFromMap(map['image']),
      dismissible: map['dismissible'] is bool ? map['dismissible'] as bool : null,
      gate: gateRaw is Map<String, dynamic> ? gateRaw : null,
      onSubmit: onSubmitRaw is Map<String, dynamic> ? onSubmitRaw : null,
      config: configRaw is Map<String, dynamic> ? configRaw : null,
      buttons: buttonsList
          .whereType<Map<String, dynamic>>()
          .map((item) => ButtonDataDTO.fromMap(item))
          .toList(),
    );
  }
}
