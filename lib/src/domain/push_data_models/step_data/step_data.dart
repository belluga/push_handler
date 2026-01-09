import 'package:push_handler/src/domain/dto/step_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/buttons_data/buttons_data.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/step_config.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/step_gate_data.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/step_submit_data.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_body_value.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_title_value.dart';

class StepData {
  final String slug;
  final String type;
  final StepDataBodyValue body;
  final StepDataTitleValue title;
  final ImageData? image;
  final bool dismissible;
  final StepGateData? gate;
  final StepSubmitData? onSubmit;
  final StepConfig? config;
  final List<ButtonData> buttons;

  StepData({
    required this.slug,
    required this.type,
    required this.body,
    required this.title,
    this.image,
    required this.dismissible,
    this.gate,
    this.onSubmit,
    this.config,
    required this.buttons,
  });

  factory StepData.fromMap(Map<String, dynamic> map) =>
      StepData.fromDTO(StepDataDTO.fromMap(map));

  factory StepData.fromDTO(StepDataDTO dto) {
    final _body = StepDataBodyValue()..tryParse(dto.body);
    final _title = StepDataTitleValue()..tryParse(dto.title);
    final _image = ImageData.tryFromDTO(dto.image);
    final gate = dto.gate != null ? StepGateData.fromMap(dto.gate!) : null;
    final onSubmit =
        dto.onSubmit != null ? StepSubmitData.fromMap(dto.onSubmit!) : null;
    final config = dto.config != null ? StepConfig(dto.config!) : null;

    return StepData(
      slug: dto.slug,
      type: dto.type,
      title: _title,
      body: _body,
      image: _image,
      dismissible: dto.dismissible ?? false,
      gate: gate,
      onSubmit: onSubmit,
      config: config,
      buttons: dto.buttons.map((e) => ButtonData.fromDTO(e)).toList(),
    );
  }
}
