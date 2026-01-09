import 'package:flutter/widgets.dart';

typedef OptionItemWidgetBuilder = Widget Function(
  BuildContext context,
  bool selected,
);

class OptionItem {
  final dynamic value;
  final String? label;
  final String? subtitle;
  final String? image;
  final OptionItemWidgetBuilder? customWidgetBuilder;

  const OptionItem({
    required this.value,
    this.label,
    this.subtitle,
    this.image,
    this.customWidgetBuilder,
  });

  factory OptionItem.fromMap(Map<String, dynamic> map) {
    return OptionItem(
      value: map['id'] ?? map['value'] ?? map['key'] ?? map['label'],
      label: map['label']?.toString(),
      subtitle: map['subtitle']?.toString(),
      image: map['image']?.toString(),
    );
  }
}
