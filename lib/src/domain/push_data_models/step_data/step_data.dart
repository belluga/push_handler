import 'package:push_handler/src/domain/dto/step_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_content_value.dart';

class StepData {
  final StepDataContentValue content;

  StepData({
    required this.content,
  });

  factory StepData.fromMap(Map<String, dynamic> map) =>
      StepData.fromDTO(StepDataDTO.fromMap(map));

  factory StepData.fromDTO(StepDataDTO dto) {
    final _content = StepDataContentValue()..tryParse(dto.content);

    return StepData(
      content: _content,
    );
  }
}
