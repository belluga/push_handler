class AnswerPayload {
  final String stepSlug;
  final dynamic value;
  final Map<String, dynamic>? metadata;

  const AnswerPayload({
    required this.stepSlug,
    required this.value,
    this.metadata,
  });
}
