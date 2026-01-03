import 'package:flutter/material.dart';
import 'package:push_handler/src/domain/dto/image_data_dto.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/value_objects/message_data_dimension_value.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/value_objects/message_data_image_url_value.dart';

class ImageData {
  final ImageDataImageURLValue pathValue;
  final MessageDataDimensionDataValue widthValue;
  final MessageDataDimensionDataValue heightValue;

  ImageData({
    required this.pathValue,
    required this.heightValue,
    required this.widthValue,
  });

  static ImageData? tryFromDTO(ImageDataDTO? dto){
    try{
      if (dto == null) {
        return null;
      }
      return ImageData.fromDTO(dto);
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  factory ImageData.fromMap(Map<String, dynamic> map) =>
      ImageData.fromDTO(ImageDataDTO.fromMap(map));

  factory ImageData.fromDTO(ImageDataDTO dto) {
    return ImageData(
      pathValue: ImageDataImageURLValue()..parse(dto.path),
      heightValue: MessageDataDimensionDataValue()
        ..tryParse(dto.height.toString()),
      widthValue: MessageDataDimensionDataValue()..tryParse(dto.width.toString()),
    );
  }
}
