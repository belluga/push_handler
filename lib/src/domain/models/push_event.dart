class PushEvent {
  final String type;
  final String pushId;
  final String? messageInstanceId;
  final String? stepSlug;
  final String? stepType;
  final String? buttonKey;
  final String? actionType;
  final String? routeKey;
  final String appState;
  final String source;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PushEvent({
    required this.type,
    required this.pushId,
    required this.appState,
    required this.source,
    required this.timestamp,
    this.messageInstanceId,
    this.stepSlug,
    this.stepType,
    this.buttonKey,
    this.actionType,
    this.routeKey,
    this.metadata,
  });
}
