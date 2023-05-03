import 'package:push_handler/src/domain/dto/step_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_body_value.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_title_value.dart';

class StepData {
  final StepDataBodyValue body;
  final StepDataTitleValue title;
  final ImageData? image;

  StepData({
    required this.body,
    required this.title,
    this.image,
  });

  factory StepData.fromMap(Map<String, dynamic> map) =>
      StepData.fromDTO(StepDataDTO.fromMap(map));

  factory StepData.fromDTO(StepDataDTO dto) {
    final _body = StepDataBodyValue()..tryParse(dto.body);
    final _title = StepDataTitleValue()..tryParse(dto.title);
    final _image = ImageData.tryFromDTO(dto.image);

    return StepData(
      title: _title,
      body: _body,
      image: _image,
    );
  }
}
