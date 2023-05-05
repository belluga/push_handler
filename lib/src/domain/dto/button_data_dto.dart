class ButtonDataDTO {
  final String label;
  final String routeType;
  final String? routeInternal;
  final String? routeExternal;
  final String? color;
  final String? itemKey;

  ButtonDataDTO({
    required this.label,
    required this.routeInternal,
    required this.routeExternal,
    required this.routeType,
    this.color,
    this.itemKey,
  });

  factory ButtonDataDTO.fromMap(Map<String, dynamic> map) {
    return ButtonDataDTO(
      label: map["label"],
      routeInternal: map['routeInternal'],
      routeExternal: map['routeExternal'],
      routeType: map['routeType'],
      color: map['color'],
      itemKey: map['itemKey'],
    );
  }
}
