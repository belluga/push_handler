class StepGateData {
  final String type;
  final String? onFailToast;
  final String? fallbackStepSlug;

  const StepGateData({
    required this.type,
    this.onFailToast,
    this.fallbackStepSlug,
  });

  factory StepGateData.fromMap(Map<String, dynamic> map) {
    final onFail = map['onFail'];
    final onFailMap = onFail is Map<String, dynamic> ? onFail : const {};
    return StepGateData(
      type: map['type']?.toString() ?? '',
      onFailToast: onFailMap['toast']?.toString(),
      fallbackStepSlug: onFailMap['fallback_step']?.toString(),
    );
  }
}
