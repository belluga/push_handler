import 'package:push_handler/src/domain/dto/step_data_dto.dart';
import 'package:push_handler/src/domain/enums/step_content_type.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_html_value.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_type_value.dart';
import 'package:push_handler/src/domain/push_data_models/step_data/value_objects/step_data_url_value.dart';

class StepData {
  final StepDataHtmlValue htmlContent;
  final StepDataURLValue embedURL;
  final StepDataContentTypeValue type;
  

  StepData({
    required this.htmlContent,
    required this.embedURL,
    required this.type,
  });

  factory StepData.fromMap(Map<String, dynamic> map) =>
      StepData.fromDTO(StepDataDTO.fromMap(map));

  factory StepData.fromDTO(StepDataDTO dto) {

    final _htmlContent = StepDataHtmlValue()..parse(dto.content);
    final _embedUrl = StepDataURLValue()..parse(dto.embedURL);
    final _type = StepDataContentTypeValue()..parse(dto.type);

    if(_type.value == StepContentType.html && _htmlContent.value.isEmpty){
      throw Exception("If the type is 'html' then 'htmlContent' should not be empty");
    }

    if(_type.value == StepContentType.embedURL && _embedUrl.value == null){
      throw Exception("If the type is 'embedURL' then 'emberUrl' should not be empty");
    }

    return StepData(
      htmlContent: _htmlContent,
      embedURL: _embedUrl,
      type: _type,
    );
  }
}
