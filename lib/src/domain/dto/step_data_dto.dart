class StepDataDTO {
  final String? content;
  final String? embedURL;
  final String type;

  StepDataDTO({
    required this.content,
    required this.embedURL,
    required this.type,
  });

  factory StepDataDTO.fromMap(Map<String, dynamic> map) {
    return StepDataDTO(
      content: map['content'],
      embedURL: map['emberUrl'],
      type: map['type'],
    );
  }
}
