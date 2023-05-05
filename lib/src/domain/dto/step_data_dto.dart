import 'package:push_handler/src/domain/dto/image_data_dto.dart';

class StepDataDTO {
  final String title;
  final String? body;
  final ImageDataDTO? image;

  StepDataDTO({
    required this.title,
    this.body,
    this.image,
  });

  factory StepDataDTO.fromMap(Map<String, dynamic> map) {
    return StepDataDTO(
        title: map['title'],
        body: map["body"],
        image: ImageDataDTO.tryFromMap(map["image"]));
  }
}
