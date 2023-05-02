class StepDataDTO {
  final String content;
  StepDataDTO({
    required this.content,
  });

  factory StepDataDTO.fromMap(Map<String, dynamic> map) {
    return StepDataDTO(
      content: map['content'],
    );
  }
}
