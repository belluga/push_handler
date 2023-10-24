import 'package:flutter/material.dart';

class ImageDataDTO {
  final String path;
  final double? width;
  final double? height;

  ImageDataDTO({
    required this.path,
    this.width,
    this.height,
  });

  static ImageDataDTO? tryFromMap(Map<String, dynamic>? map) {
    try {
      return ImageDataDTO.fromMap(map!);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  factory ImageDataDTO.fromMap(Map<String, dynamic> map) {
    return ImageDataDTO(
      path: map["path"],
      width: double.tryParse(map['width'].toString()),
      height: double.tryParse(map['height'].toString()),
    );
  }
}
